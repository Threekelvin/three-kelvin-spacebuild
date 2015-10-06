TK.DB = TK.DB or {}

local threekelvin = {
    server_ban_data = {
        idx = {
            "INT",
            "PRIMARY KEY",
            "AUTO_INCREMENT",
            type = "number"
        },
        ply_steamid = {
            "VARCHAR(20)",
            type = "string"
        },
        ply_ip = {
            "VARCHAR(40)",
            type = "string"
        },
        ban_start = {
            "INT",
            "NOT NULL",
            type = "number",
            p_h = true
        },
        ban_lenght = {
            "INT",
            "NOT NULL",
            type = "number"
        },
        ban_reason = {
            "LONGTEXT",
            type = "string"
        },
        ban_lifted = {
            "BIT",
            "DEFAULT 0",
            type = "boolean"
        },
        adm_steamid = {
            "VARCHAR(20)",
            type = "string"
        },
        adm_ip = {
            "VARCHAR(40)",
            type = "string"
        }
    },
    server_donations = {
        idx = {
            "INT",
            "PRIMARY KEY",
            "AUTO_INCREMENT",
            type = "number"
        },
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            type = "string"
        },
        time = {
            "INT",
            "DEFAULT 0",
            "NOT NULL",
            type = "number"
        },
        amount = {
            "INT",
            "DEFAULT 0",
            type = "number"
        }
    },
    server_globalchat = {
        msg_idx = {
            "INT",
            "PRIMARY KEY",
            "AUTO_INCREMENT",
            type = "number"
        },
        msg_conection_id = {
            "INT",
            "DEFAULT 0",
            type = "number",
            p_h = true
        },
        msg_key = {
            "TINYINT",
            "DEFAULT 0",
            type = "number"
        },
        msg_origin = {
            "VARCHAR(127)",
            type = "string"
        },
        msg_recipient = {
            "VARCHAR(127)",
            type = "string"
        },
        msg_flag = {
            "TINYINT",
            "DEFAULT 0",
            type = "number"
        },
        msg_data = {
            "LONGBLOB",
            type = "string"
        },
        sender_rank = {
            "TINYINT",
            "DEFAULT 1",
            type = "number"
        },
        sender_faction = {
            "TINYINT",
            "DEFAULT 1",
            type = "number"
        },
        sender_name = {
            "VARCHAR(127)",
            type = "string"
        }
    },
    server_player_record = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string"
        },
        ip = {
            "VARCHAR(40)",
            "NOT NULL",
            type = "string"
        },
        uniqueid = {
            "VARCHAR(10)",
            "NOT NULL",
            type = "string"
        },
        steam_name = {
            "VARCHAR(127)",
            "NOT NULL",
            type = "string"
        },
        nick_name = {
            "VARCHAR(127)",
            "NOT NULL",
            type = "string"
        },
        rank = {
            "TINYINT",
            "DEFAULT 1",
            type = "number"
        },
        team = {
            "TINYINT",
            "DEFAULT 1",
            type = "number"
        }
    },
    player_stats = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        playtime = {
            "INT",
            "DEFAULT 0",
            type = "number",
            no_sync = true
        },
        score = {
            "FLOAT",
            "DEFAULT 0",
            type = "number",
            no_sync = true
        }
    },
    player_settings = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        captcha = {
            "VARCHAR(127)",
            "DEFAULT 'abcde'",
            type = "string",
            no_sync = true
        }
    },
    player_terminal_storage = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        storage = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {}
        }
    },
    player_terminal_inventory = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        inventory = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {"basic_asteroid_laser",  "basic_asteroid_storage",  "basic_tiberium_extractor",  "basic_tiberium_storage"}
        }
    },
    player_terminal_loadout = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        loadout = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {}
        },
        slots = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {
                mining_1 = true,
                storage_1 = true
            }
        }
    },
    player_upgrades_mining = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        upgrades = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {}
        }
    },
    player_upgrades_life_support = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        upgrades = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {}
        }
    },
    player_upgrades_subsystem = {
        steamid = {
            "VARCHAR(20)",
            "NOT NULL",
            "PRIMARY KEY",
            type = "string",
            no_sync = true
        },
        upgrades = {
            "LONGBLOB",
            "NOT NULL",
            type = "table",
            default = {}
        }
    }
}

for idx, data in pairs(threekelvin) do
    list.Set("TK_Database", idx, data)
end

function TK.DB:NoSync(dbtable, idx)
    if not threekelvin[dbtable] then return end
    if not threekelvin[dbtable][idx] then return end

    return threekelvin[dbtable][idx].no_sync and true or false
end

function TK.DB:GetKey(dbtable)
    if not threekelvin[dbtable] then return end

    for idx, val in pairs(threekelvin[dbtable]) do
        for k, v in pairs(val) do
            if v ~= "PRIMARY KEY" then continue end

            return idx
        end
    end
end
