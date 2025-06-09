module leaderboard::leaderboard {
    use std::vector;
    use std::signer;
    use aptos_framework::timestamp;

    /// Error codes
    const E_INVALID_LEADERBOARD_SIZE: u64 = 1;
    const E_LEADERBOARD_NOT_FOUND: u64 = 2;

    /// Maximum number of entries in leaderboard
    const MAX_LEADERBOARD_SIZE: u64 = 10;

    /// Represents a single leaderboard entry
    struct LeaderboardEntry has copy, drop, store {
        user_address: address,
        score: u64,
    }

    /// Main leaderboard resource that stores the current state
    struct Leaderboard has key {
        entries: vector<LeaderboardEntry>,
        last_updated: u64,
        update_count: u64,
    }

    /// Historical leaderboard data for tracking past states
    struct LeaderboardHistory has key {
        historical_boards: vector<HistoricalBoard>,
    }

    /// Historical leaderboard snapshot
    struct HistoricalBoard has copy, drop, store {
        entries: vector<LeaderboardEntry>,
        timestamp: u64,
        update_number: u64,
    }

    /// Initialize the leaderboard module
    public entry fun initialize(account: &signer) {
        let account_addr = signer::address_of(account);
        
        // Check if already initialized
        assert!(!exists<Leaderboard>(account_addr), 100);
        
        // Initialize empty leaderboard
        let leaderboard = Leaderboard {
            entries: vector::empty<LeaderboardEntry>(),
            last_updated: timestamp::now_seconds(),
            update_count: 0,
        };

        // Initialize history tracking
        let history = LeaderboardHistory {
            historical_boards: vector::empty<HistoricalBoard>(),
        };

        move_to(account, leaderboard);
        move_to(account, history);
    }

    /// Upload a new leaderboard with 10 entries
    public entry fun upload_leaderboard(
        account: &signer,
        addresses: vector<address>,
        scores: vector<u64>
    ) acquires Leaderboard, LeaderboardHistory {
        let account_addr = signer::address_of(account);
        
        // Check if leaderboard exists
        assert!(exists<Leaderboard>(account_addr), E_LEADERBOARD_NOT_FOUND);
        
        let leaderboard = borrow_global_mut<Leaderboard>(account_addr);
        
        // Validate input vectors
        let addr_len = vector::length(&addresses);
        let score_len = vector::length(&scores);
        assert!(addr_len == score_len && addr_len == MAX_LEADERBOARD_SIZE, E_INVALID_LEADERBOARD_SIZE);

        // Store current leaderboard in history before updating
        if (vector::length(&leaderboard.entries) > 0) {
            let history = borrow_global_mut<LeaderboardHistory>(account_addr);
            let historical_board = HistoricalBoard {
                entries: leaderboard.entries,
                timestamp: leaderboard.last_updated,
                update_number: leaderboard.update_count,
            };
            vector::push_back(&mut history.historical_boards, historical_board);
        };

        // Create new entries
        let new_entries = vector::empty<LeaderboardEntry>();
        let i = 0;
        while (i < addr_len) {
            let entry = LeaderboardEntry {
                user_address: *vector::borrow(&addresses, i),
                score: *vector::borrow(&scores, i),
            };
            vector::push_back(&mut new_entries, entry);
            i = i + 1;
        };

        // Update leaderboard
        leaderboard.entries = new_entries;
        leaderboard.last_updated = timestamp::now_seconds();
        leaderboard.update_count = leaderboard.update_count + 1;
    }

    /// Get current leaderboard
    #[view]
    public fun get_current_leaderboard(leaderboard_owner: address): (vector<address>, vector<u64>, u64, u64) acquires Leaderboard {
        assert!(exists<Leaderboard>(leaderboard_owner), E_LEADERBOARD_NOT_FOUND);
        
        let leaderboard = borrow_global<Leaderboard>(leaderboard_owner);
        let addresses = vector::empty<address>();
        let scores = vector::empty<u64>();
        
        let i = 0;
        let len = vector::length(&leaderboard.entries);
        while (i < len) {
            let entry = vector::borrow(&leaderboard.entries, i);
            vector::push_back(&mut addresses, entry.user_address);
            vector::push_back(&mut scores, entry.score);
            i = i + 1;
        };

        (addresses, scores, leaderboard.last_updated, leaderboard.update_count)
    }

    /// Get leaderboard info
    #[view]
    public fun get_leaderboard_info(leaderboard_owner: address): (u64, u64) acquires Leaderboard {
        assert!(exists<Leaderboard>(leaderboard_owner), E_LEADERBOARD_NOT_FOUND);
        
        let leaderboard = borrow_global<Leaderboard>(leaderboard_owner);
        (leaderboard.last_updated, leaderboard.update_count)
    }

    /// Get user score from current leaderboard
    #[view]
    public fun get_user_score(leaderboard_owner: address, user_addr: address): u64 acquires Leaderboard {
        assert!(exists<Leaderboard>(leaderboard_owner), E_LEADERBOARD_NOT_FOUND);
        
        let leaderboard = borrow_global<Leaderboard>(leaderboard_owner);
        let i = 0;
        let len = vector::length(&leaderboard.entries);
        
        while (i < len) {
            let entry = vector::borrow(&leaderboard.entries, i);
            if (entry.user_address == user_addr) {
                return entry.score
            };
            i = i + 1;
        };
        
        0 // Return 0 if user not found
    }

    /// Get user rank in current leaderboard (1-indexed, 0 if not found)
    #[view]
    public fun get_user_rank(leaderboard_owner: address, user_addr: address): u64 acquires Leaderboard {
        assert!(exists<Leaderboard>(leaderboard_owner), E_LEADERBOARD_NOT_FOUND);
        
        let leaderboard = borrow_global<Leaderboard>(leaderboard_owner);
        let i = 0;
        let len = vector::length(&leaderboard.entries);
        
        while (i < len) {
            let entry = vector::borrow(&leaderboard.entries, i);
            if (entry.user_address == user_addr) {
                return i + 1 // Return 1-indexed rank
            };
            i = i + 1;
        };
        
        0 // Return 0 if user not found
    }

    /// Get historical leaderboard count
    #[view]
    public fun get_history_count(leaderboard_owner: address): u64 acquires LeaderboardHistory {
        if (!exists<LeaderboardHistory>(leaderboard_owner)) {
            return 0
        };
        
        let history = borrow_global<LeaderboardHistory>(leaderboard_owner);
        vector::length(&history.historical_boards)
    }

    /// Get historical leaderboard by index
    #[view]
    public fun get_historical_leaderboard(leaderboard_owner: address, index: u64): (vector<address>, vector<u64>, u64, u64) acquires LeaderboardHistory {
        assert!(exists<LeaderboardHistory>(leaderboard_owner), E_LEADERBOARD_NOT_FOUND);
        
        let history = borrow_global<LeaderboardHistory>(leaderboard_owner);
        let historical_board = vector::borrow(&history.historical_boards, index);
        
        let addresses = vector::empty<address>();
        let scores = vector::empty<u64>();
        
        let i = 0;
        let len = vector::length(&historical_board.entries);
        while (i < len) {
            let entry = vector::borrow(&historical_board.entries, i);
            vector::push_back(&mut addresses, entry.user_address);
            vector::push_back(&mut scores, entry.score);
            i = i + 1;
        };

        (addresses, scores, historical_board.timestamp, historical_board.update_number)
    }
}