-- 🎯 SABO Arena Auto Tournament Progression Database Trigger
-- This trigger automatically advances winners when matches are completed

-- Create function to handle match completion and advancement
CREATE OR REPLACE FUNCTION handle_match_completion()
RETURNS TRIGGER AS $$
DECLARE
    tournament_format TEXT;
    current_round INTEGER;
    next_round INTEGER;
    next_match_number INTEGER;
    winner_matches RECORD;
    advance_count INTEGER := 0;
BEGIN
    -- Only process if match status changed to 'completed' and has a winner
    IF NEW.status = 'completed' AND NEW.winner_id IS NOT NULL AND 
       (OLD.status != 'completed' OR OLD.winner_id IS NULL) THEN
        
        -- Get tournament format
        SELECT format INTO tournament_format 
        FROM tournaments 
        WHERE id = NEW.tournament_id;
        
        -- Log the completion
        RAISE NOTICE 'Match M% completed in tournament %, winner: %', 
                     NEW.match_number, NEW.tournament_id, NEW.winner_id;
        
        -- Handle single elimination advancement
        IF tournament_format = 'single_elimination' THEN
            current_round := NEW.round_number;
            next_round := current_round + 1;
            
            -- Calculate next match number based on current round
            IF current_round = 1 THEN
                -- Round 1 -> Round 2: M1,M2->M9, M3,M4->M10, M5,M6->M11, M7,M8->M12
                next_match_number := 8 + ((NEW.match_number + 1) / 2)::INTEGER;
            ELSIF current_round = 2 THEN
                -- Round 2 -> Round 3: M9,M10->M13, M11,M12->M14
                next_match_number := 12 + ((NEW.match_number - 8) / 2)::INTEGER;
            ELSIF current_round = 3 THEN
                -- Round 3 -> Finals: M13,M14->M15
                next_match_number := 15;
            ELSE
                -- No more rounds
                RETURN NEW;
            END IF;
            
            -- Check if we have a pair of completed matches to advance
            SELECT COUNT(*) INTO advance_count
            FROM matches 
            WHERE tournament_id = NEW.tournament_id 
              AND round_number = current_round 
              AND status = 'completed' 
              AND winner_id IS NOT NULL
              AND (
                  (current_round = 1 AND match_number IN (
                      CASE 
                          WHEN NEW.match_number <= 2 THEN 1, 2
                          WHEN NEW.match_number <= 4 THEN 3, 4
                          WHEN NEW.match_number <= 6 THEN 5, 6
                          ELSE 7, 8
                      END
                  )) OR
                  (current_round = 2 AND match_number IN (
                      CASE 
                          WHEN NEW.match_number <= 10 THEN 9, 10
                          ELSE 11, 12
                      END
                  )) OR
                  (current_round = 3 AND match_number IN (13, 14))
              );
            
            -- If we have a complete pair, advance both winners
            IF advance_count = 2 THEN
                -- Get the two winners to advance
                FOR winner_matches IN 
                    SELECT winner_id, match_number
                    FROM matches 
                    WHERE tournament_id = NEW.tournament_id 
                      AND round_number = current_round 
                      AND status = 'completed' 
                      AND winner_id IS NOT NULL
                      AND (
                          (current_round = 1 AND match_number IN (
                              CASE 
                                  WHEN NEW.match_number <= 2 THEN 1, 2
                                  WHEN NEW.match_number <= 4 THEN 3, 4
                                  WHEN NEW.match_number <= 6 THEN 5, 6
                                  ELSE 7, 8
                              END
                          )) OR
                          (current_round = 2 AND match_number IN (
                              CASE 
                                  WHEN NEW.match_number <= 10 THEN 9, 10
                                  ELSE 11, 12
                              END
                          )) OR
                          (current_round = 3 AND match_number IN (13, 14))
                      )
                    ORDER BY match_number
                LOOP
                    -- Update next round match with winners
                    IF winner_matches.match_number % 2 = 1 THEN
                        -- Odd match number -> player1 in next match
                        UPDATE matches 
                        SET player1_id = winner_matches.winner_id,
                            status = CASE 
                                WHEN player2_id IS NOT NULL THEN 'pending'
                                ELSE status 
                            END
                        WHERE tournament_id = NEW.tournament_id 
                          AND round_number = next_round 
                          AND match_number = next_match_number;
                    ELSE
                        -- Even match number -> player2 in next match
                        UPDATE matches 
                        SET player2_id = winner_matches.winner_id,
                            status = CASE 
                                WHEN player1_id IS NOT NULL THEN 'pending'
                                ELSE 'scheduled' 
                            END
                        WHERE tournament_id = NEW.tournament_id 
                          AND round_number = next_round 
                          AND match_number = next_match_number;
                    END IF;
                END LOOP;
                
                RAISE NOTICE 'Advanced winners to Round % Match %', next_round, next_match_number;
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS trigger_match_completion ON matches;

-- Create trigger on matches table
CREATE TRIGGER trigger_match_completion
    AFTER UPDATE ON matches
    FOR EACH ROW
    EXECUTE FUNCTION handle_match_completion();

-- Enable the trigger
ALTER TABLE matches ENABLE TRIGGER trigger_match_completion;

-- Add helpful comments
COMMENT ON FUNCTION handle_match_completion() IS 'Auto-advances tournament winners when matches are completed';
COMMENT ON TRIGGER trigger_match_completion ON matches IS 'Automatically processes tournament progression when matches are completed';

-- Test the trigger setup
SELECT 'Tournament Auto-Progression Trigger installed successfully!' as status;