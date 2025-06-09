module 0x8837d532ada7d8fedef2d9a3c1c017a2ec12b8a3096779ae5c554ed1728c1abc::top_players {
    use std::signer;

    // Error codes
    const E_NOT_ADMIN: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_NOT_INITIALIZED: u64 = 3;

    // Badge types
    const GOLD_BADGE: u8 = 1;
    const SILVER_BADGE: u8 = 2;
    const BRONZE_BADGE: u8 = 3;

    // Struct to store player information
    struct Player has store, drop, copy {
        player_address: address,
        badge: u8, // 1 = Gold, 2 = Silver, 3 = Bronze
    }

    // Resource to store top players and admin info
    struct TopPlayersBoard has key {
        admin: address,
        gold_player: Player,
        silver_player: Player,
        bronze_player: Player,
    }

    // Initialize the contract (can only be called once by the admin)
    public entry fun initialize(
        admin: &signer,
        initial_gold: address,
        initial_silver: address,
        initial_bronze: address
    ) {
        let admin_addr = signer::address_of(admin);
        
        // Check if already initialized
        assert!(!exists<TopPlayersBoard>(admin_addr), E_ALREADY_INITIALIZED);

        // Create initial players
        let gold_player = Player {
            player_address: initial_gold,
            badge: GOLD_BADGE,
        };
        
        let silver_player = Player {
            player_address: initial_silver,
            badge: SILVER_BADGE,
        };
        
        let bronze_player = Player {
            player_address: initial_bronze,
            badge: BRONZE_BADGE,
        };

        // Create and store the board
        let board = TopPlayersBoard {
            admin: admin_addr,
            gold_player,
            silver_player,
            bronze_player,
        };

        move_to(admin, board);
    }

    // Update all three players (admin only)
    public entry fun update_top_players(
        admin: &signer,
        new_gold: address,
        new_silver: address,
        new_bronze: address
    ) acquires TopPlayersBoard {
        let admin_addr = signer::address_of(admin);
        
        // Check if initialized
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        
        // Verify admin
        assert!(board.admin == admin_addr, E_NOT_ADMIN);

        // Update players
        board.gold_player = Player {
            player_address: new_gold,
            badge: GOLD_BADGE,
        };
        
        board.silver_player = Player {
            player_address: new_silver,
            badge: SILVER_BADGE,
        };
        
        board.bronze_player = Player {
            player_address: new_bronze,
            badge: BRONZE_BADGE,
        };
    }

    // Update individual player (admin only)
    public entry fun update_player(
        admin: &signer,
        badge_type: u8,
        new_player: address
    ) acquires TopPlayersBoard {
        let admin_addr = signer::address_of(admin);
        
        // Check if initialized
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        
        // Verify admin
        assert!(board.admin == admin_addr, E_NOT_ADMIN);

        // Update specific player based on badge type
        if (badge_type == GOLD_BADGE) {
            board.gold_player = Player {
                player_address: new_player,
                badge: GOLD_BADGE,
            };
        } else if (badge_type == SILVER_BADGE) {
            board.silver_player = Player {
                player_address: new_player,
                badge: SILVER_BADGE,
            };
        } else if (badge_type == BRONZE_BADGE) {
            board.bronze_player = Player {
                player_address: new_player,
                badge: BRONZE_BADGE,
            };
        };
    }

    // View functions

    #[view]
    public fun get_all_players(admin_addr: address): (address, address, address) acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        (
            board.gold_player.player_address,
            board.silver_player.player_address,
            board.bronze_player.player_address
        )
    }

    #[view]
    public fun get_gold_player(admin_addr: address): address acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        board.gold_player.player_address
    }

    #[view]
    public fun get_silver_player(admin_addr: address): address acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        board.silver_player.player_address
    }

    #[view]
    public fun get_bronze_player(admin_addr: address): address acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        board.bronze_player.player_address
    }

    #[view]
    public fun get_player_by_badge(admin_addr: address, badge_type: u8): address acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        
        if (badge_type == GOLD_BADGE) {
            board.gold_player.player_address
        } else if (badge_type == SILVER_BADGE) {
            board.silver_player.player_address
        } else {
            board.bronze_player.player_address
        }
    }

    #[view]
    public fun is_initialized(admin_addr: address): bool {
        exists<TopPlayersBoard>(admin_addr)
    }

    #[view]
    public fun get_admin(admin_addr: address): address acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        board.admin
    }
}