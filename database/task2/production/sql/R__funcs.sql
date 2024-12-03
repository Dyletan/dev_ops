CREATE OR REPLACE FUNCTION get_recommendations_by_user_id(p_user_id UUID, p_limit INT DEFAULT 10)
RETURNS TABLE (movie_id UUID, title VARCHAR, genre VARCHAR, release_date DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.movie_id, m.title, m.genre, m.release_date
    FROM 
        public.movie m
    WHERE 
        NOT EXISTS (
            SELECT 1 
            FROM public.reaction r
            WHERE r.user_id = p_user_id AND r.movie_id = m.movie_id
        )
    ORDER BY random()
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_recommendations_by_device_id(p_device_id UUID, p_limit INT DEFAULT 10)
RETURNS TABLE (movie_id UUID, title VARCHAR, genre VARCHAR, release_date DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.movie_id, m.title, m.genre, m.release_date
    FROM 
        public.movie m
    WHERE 
        NOT EXISTS (
            SELECT 1 
            FROM public.reaction r
            WHERE r.device_id = p_device_id AND r.movie_id = m.movie_id
        )
    ORDER BY random()
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
