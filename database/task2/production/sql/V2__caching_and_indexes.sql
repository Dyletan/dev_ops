CREATE MATERIALIZED VIEW cached_movie_recommendations AS
SELECT movie_id, title, genre, release_date
FROM public.movie;
REFRESH MATERIALIZED VIEW cached_movie_recommendations;

CREATE INDEX idx_reaction_device_movie ON public.reaction (device_id, movie_id);
CREATE INDEX idx_reaction_user_movie ON public.reaction (user_id, movie_id);
CREATE INDEX idx_user_recommendation_iin_movie ON public.user_recommendation (iin, movie_id);
CREATE INDEX idx_movie_movie_id ON public.movie (movie_id);
