module top_players_prize_new::top_players_prize_new {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::account;

    // Error codes
    const E_NOT_ADMIN: u64 = 1;
    const E_ALREADY_INITIALIZED: u64 = 2;
    const E_NOT_INITIALIZED: u64 = 3;
    const E_INSUFFICIENT_FUNDS: u64 = 4;
    const E_INVALID_BADGE_TYPE: u64 = 5;
    const E_ACCOUNT_NOT_REGISTERED: u64 = 6;

    // Badge types
    const GOLD_BADGE: u8 = 1;
    const SILVER_BADGE: u8 = 2;
    const BRONZE_BADGE: u8 = 3;

    // Reward amounts in octas (1 APT = 100,000,000 octas)
    const GOLD_REWARD: u64 = 50000000;   // 0.5 APT
    const SILVER_REWARD: u64 = 30000000; // 0.3 APT
    const BRONZE_REWARD: u64 = 20000000; // 0.2 APT

    // Struct to store player information
    struct Player has store, drop, copy {
        player_address: address,
        badge: u8,
    }

    // Resource to store top players
    struct TopPlayersBoard has key {
        admin: address,
        gold_player: Player,
        silver_player: Player,
        bronze_player: Player,
        reward_pool: coin::Coin<AptosCoin>,
    }

    // Helper function to validate badge type
    fun is_valid_badge_type(badge_type: u8): bool {
        badge_type == GOLD_BADGE || badge_type == SILVER_BADGE || badge_type == BRONZE_BADGE
    }

    // Initialize the contract
    public entry fun initialize(
        admin: &signer,
        initial_gold: address,
        initial_silver: address,
        initial_bronze: address
    ) {
        let admin_addr = signer::address_of(admin);
        
        assert!(!exists<TopPlayersBoard>(admin_addr), E_ALREADY_INITIALIZED);

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

        let reward_pool = coin::zero<AptosCoin>();

        let board = TopPlayersBoard {
            admin: admin_addr,
            gold_player,
            silver_player,
            bronze_player,
            reward_pool,
        };

        move_to(admin, board);
    }

    // Deposit funds
    public entry fun deposit_funds(
        depositor: &signer,
        admin_addr: address,
        amount: u64
    ) acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        let deposit_coins = coin::withdraw<AptosCoin>(depositor, amount);
        coin::merge(&mut board.reward_pool, deposit_coins);
    }

    // Check if there are sufficient funds for all rewards
    fun has_sufficient_funds(board: &TopPlayersBoard): bool {
        let total_rewards = GOLD_REWARD + SILVER_REWARD + BRONZE_REWARD;
        coin::value(&board.reward_pool) >= total_rewards
    }

    // Distribute rewards with proper checks
    fun distribute_rewards_safe(
        board: &mut TopPlayersBoard,
        gold_addr: address,
        silver_addr: address,
        bronze_addr: address
    ) {
        // Check if all accounts exist and are registered for APT
        assert!(account::exists_at(gold_addr), E_ACCOUNT_NOT_REGISTERED);
        assert!(account::exists_at(silver_addr), E_ACCOUNT_NOT_REGISTERED);
        assert!(account::exists_at(bronze_addr), E_ACCOUNT_NOT_REGISTERED);
        
        assert!(coin::is_account_registered<AptosCoin>(gold_addr), E_ACCOUNT_NOT_REGISTERED);
        assert!(coin::is_account_registered<AptosCoin>(silver_addr), E_ACCOUNT_NOT_REGISTERED);
        assert!(coin::is_account_registered<AptosCoin>(bronze_addr), E_ACCOUNT_NOT_REGISTERED);

        // Extract reward coins from the pool
        let gold_coins = coin::extract(&mut board.reward_pool, GOLD_REWARD);
        let silver_coins = coin::extract(&mut board.reward_pool, SILVER_REWARD);
        let bronze_coins = coin::extract(&mut board.reward_pool, BRONZE_REWARD);

        // Deposit rewards to player accounts
        coin::deposit(gold_addr, gold_coins);
        coin::deposit(silver_addr, silver_coins);
        coin::deposit(bronze_addr, bronze_coins);
    }

    // Update all three players with rewards (only if all can receive)
    public entry fun update_top_players(
        admin: &signer,
        new_gold: address,
        new_silver: address,
        new_bronze: address
    ) acquires TopPlayersBoard {
        let admin_addr = signer::address_of(admin);
        
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        
        // Verify admin
        assert!(board.admin == admin_addr, E_NOT_ADMIN);

        // Check if there are sufficient funds for rewards
        assert!(has_sufficient_funds(board), E_INSUFFICIENT_FUNDS);

        // Distribute rewards to new top players
        distribute_rewards_safe(board, new_gold, new_silver, new_bronze);

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

    // Update players without rewards (safer option)
    public entry fun update_top_players_no_rewards(
        admin: &signer,
        new_gold: address,
        new_silver: address,
        new_bronze: address
    ) acquires TopPlayersBoard {
        let admin_addr = signer::address_of(admin);
        
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        
        // Verify admin
        assert!(board.admin == admin_addr, E_NOT_ADMIN);

        // Update players without distributing rewards
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

    // Distribute rewards to current players (call separately)
    public entry fun distribute_current_rewards(
        admin: &signer
    ) acquires TopPlayersBoard {
        let admin_addr = signer::address_of(admin);
        
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        
        // Verify admin
        assert!(board.admin == admin_addr, E_NOT_ADMIN);

        // Check if there are sufficient funds for rewards
        assert!(has_sufficient_funds(board), E_INSUFFICIENT_FUNDS);

        let gold_addr = board.gold_player.player_address;
        let silver_addr = board.silver_player.player_address;
        let bronze_addr = board.bronze_player.player_address;

        distribute_rewards_safe(board, gold_addr, silver_addr, bronze_addr);
    }

    // Register a player for APT coins (they must call this themselves)
    public entry fun register_for_apt(account: &signer) {
        if (!coin::is_account_registered<AptosCoin>(signer::address_of(account))) {
            coin::register<AptosCoin>(account);
        }
    }

    // Withdraw funds from the contract (admin only)
    public entry fun withdraw_funds(
        admin: &signer,
        amount: u64
    ) acquires TopPlayersBoard {
        let admin_addr = signer::address_of(admin);
        
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        
        let board = borrow_global_mut<TopPlayersBoard>(admin_addr);
        
        // Verify admin
        assert!(board.admin == admin_addr, E_NOT_ADMIN);

        // Extract coins from the reward pool and deposit to admin
        let withdraw_coins = coin::extract(&mut board.reward_pool, amount);
        coin::deposit(admin_addr, withdraw_coins);
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
    public fun is_initialized(admin_addr: address): bool {
        exists<TopPlayersBoard>(admin_addr)
    }

    #[view]
    public fun get_reward_pool_balance(admin_addr: address): u64 acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        coin::value(&board.reward_pool)
    }

    #[view]
    public fun can_receive_rewards(
        admin_addr: address
    ): (bool, bool, bool) acquires TopPlayersBoard {
        assert!(exists<TopPlayersBoard>(admin_addr), E_NOT_INITIALIZED);
        let board = borrow_global<TopPlayersBoard>(admin_addr);
        
        let gold_can_receive = account::exists_at(board.gold_player.player_address) && 
                              coin::is_account_registered<AptosCoin>(board.gold_player.player_address);
        let silver_can_receive = account::exists_at(board.silver_player.player_address) && 
                                coin::is_account_registered<AptosCoin>(board.silver_player.player_address);
        let bronze_can_receive = account::exists_at(board.bronze_player.player_address) && 
                                coin::is_account_registered<AptosCoin>(board.bronze_player.player_address);
        
        (gold_can_receive, silver_can_receive, bronze_can_receive)
    }

    #[view]
    public fun get_total_rewards_needed(): u64 {
        GOLD_REWARD + SILVER_REWARD + BRONZE_REWARD
    }

    #[view]
    public fun get_reward_amount(badge_type: u8): u64 {
        assert!(is_valid_badge_type(badge_type), E_INVALID_BADGE_TYPE);
        
        if (badge_type == GOLD_BADGE) {
            GOLD_REWARD
        } else if (badge_type == SILVER_BADGE) {
            SILVER_REWARD
        } else {
            BRONZE_REWARD
        }
    }

    // Test function
    #[view]
    public fun test_connection(): u64 {
        42
    }
}
