# rzw-starterpack

Modern, simple, lightweight, and highly optimized starter pack resource for **FiveM (ESX Framework)** powered by the **Overextended (ox)** ecosystem.

![FiveM](https://img.shields.io/badge/FiveM-Resource-orange?style=for-the-badge&logo=fivem&logoColor=white)
![ESX](https://img.shields.io/badge/Framework-ESX%20Legacy-blue?style=for-the-badge)
![Ox](https://img.shields.io/badge/Ecosystem-ox__lib%20%7C%20ox__target%20%7C%20ox__inventory-red?style=for-the-badge)
![Resmon](https://img.shields.io/badge/Resmon-0.00ms-brightgreen?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-2.0.0-informational?style=for-the-badge)

---

## Overview

**rzw-starterpack** allows players to claim a welcome kit / starterpack on your FiveM server. Built with performance and security in mind, this script utilizes **in-memory server caching**, server-side validation callbacks, and `ox_target` zones to guarantee a smooth **0.00ms idle resmon**.

---

## Key Features

- **Zero Idle Resmon (0.00 ms)**:
  - Uses `ox_target:addSphereZone` instead of polling loops (`while true do`). Zero performance impact on client CPU cycles.
- **Server-Side In-Memory Cache**:
  - Validated claims are cached into `StarterpackDataCache` in server memory.
  - Eliminates redundant SQL database queries when players verify claim status.
- **Secure Anti-Exploit System**:
  - Two-stage validation: Client callback pre-check (`lib.callback.await`) before triggering animations, followed by an authoritative server-side check before items are granted.
  - Prevents double-claiming and event manipulation.
- **Auto Database Setup**:
  - Automatically checks and creates the SQL table `rzw_starterpack` upon resource start. No manual SQL import required.
- **Multi-Location & Modular NPC Peds**:
  - Configure one or more starterpack claim locations.
  - Optional ambient NPC spawning with invincibility, ragdoll protection, and freeze position.
- **Native ox_inventory Support**:
  - Direct server-side distribution of configured items and cash straight into the player's inventory.
- **Claim History & Timestamp Notification**:
  - Stores claim timestamps (`os.time()`).
  - Displays localized date and time (`os.date("%d %B %Y | %H:%M")`) if a player attempts to claim again.

---

## Dependencies

Ensure the following dependencies are installed and started before `rzw-starterpack`:

| Dependency | Purpose | Link |
| :--- | :--- | :--- |
| **es_extended** | Core ESX framework (xPlayer, identifier, etc.) | [esx-framework/es_extended](https://github.com/esx-framework/esx_core) |
| **ox_lib** | UI notifications, progress bar, callbacks, cache loader | [overextended/ox_lib](https://github.com/overextended/ox_lib) |
| **ox_target** | Optimized interaction zone system | [overextended/ox_target](https://github.com/overextended/ox_target) |
| **ox_inventory** | Inventory item management & distribution | [overextended/ox_inventory](https://github.com/overextended/ox_inventory) |
| **oxmysql** | Async database wrapper for MySQL queries | [overextended/oxmysql](https://github.com/overextended/oxmysql) |

---

## Installation

1. **Download / Clone** this repository to your FiveM server resources folder:
   ```bash
   cd resources/[ADDON]
   git clone https://github.com/your-username/rzw-starterpack.git
   ```

2. **Server Configuration**:
   Add the resource execution order in your `server.cfg`:
   ```cfg
   ensure oxmysql
   ensure es_extended
   ensure ox_lib
   ensure ox_target
   ensure ox_inventory

   # Add rzw-starterpack after dependencies
   ensure rzw-starterpack
   ```

3. **Database Migration**:
   - **Automatic**: You do not need to import any SQL file. The script will execute the `CREATE TABLE IF NOT EXISTS` migration query automatically on first startup.

4. **Restart Server** or run `ensure rzw-starterpack` in your server console.

---

## Configuration (`shared/main.lua`)

You can easily adjust claim coordinates, NPC ped models, and rewarded starterpack items in `shared/main.lua`:

```lua
local Config = {}

-- Starterpack interaction points
Config.Location = {
    {
        coords = vector4(127.2675, 6640.1904, 31.8033, 139.4229),
        ped = "s_m_m_fiboffice_01", -- Optional ped model (set nil or '' to disable NPC)
    },
    {
        coords = vector4(131.8801, 6638.3784, 31.7917, 228.9135),
        -- Without ped, ox_target sphere zone will still be placed at coords
    },
}

-- Items given to the player upon claiming
Config.Items = {
    {
        item = 'water',
        count = 10,
    },
    {
        item = 'burger',
        count = 10,
    },
    {
        item = 'money',
        count = 150000,
    },
}

return Config
```

---

## Database Structure

The resource automatically creates and maintains the following table schema:

```sql
CREATE TABLE IF NOT EXISTS `rzw_starterpack` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(150) NOT NULL,
    `name` varchar(250) NOT NULL,
    `time` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
);
```

---

## Cache Optimization Details

```
Player Interacts -> Client Callback
                          │
                          ▼
            [Server Checking Function]
                          │
                 Is Identifier in
             self.StarterpackDataCache?
                     /          \
                   YES           NO
                   /              \
        Return Cached Data     Query MySQL (oxmysql)
       (0 SQL Queries Executed)       │
                               Store to Cache
                                      │
                                Return Result
```

1. **Instant Memory Lookup**: Once a player interacts, their claim status is stored in the Lua table `self.StarterpackDataCache`.
2. **Reduced DB Overhead**: Successive interactions by the same player bypass database queries completely and return instant UI notifications.

---

## Performance Benchmark

| State | Resmon CPU | Notes |
| :--- | :--- | :--- |
| **Idle** | `0.00 ms` | Handled entirely by `ox_target` sphere zones. |
| **Interacting** | `0.01 ms` | Running progress bar and scenario anim via `ox_lib`. |
| **Server Thread** | `< 0.01 ms` | Database queries are non-blocking async (`MySQL.single.await` / `MySQL.insert.await`) with in-memory cache lookup. |

---

## Author

- **Author**: Rozir Wobari
- **Version**: 2.0.0
- **Framework**: ESX Legacy + Overextended
