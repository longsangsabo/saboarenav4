-- Test tournament creation after cleanup
INSERT INTO tournaments (
    title, 
    description, 
    start_date, 
    end_date, 
    registration_deadline,
    max_participants, 
    format, 
    status,
    entry_fee,
    prize_pool
) VALUES (
    'Cleanup Test Tournament',
    'Testing after schema cleanup', 
    '2025-01-01',
    '2025-01-02',
    '2024-12-31',
    16,
    'single_elimination',
    'upcoming',
    50000,
    1000000
);