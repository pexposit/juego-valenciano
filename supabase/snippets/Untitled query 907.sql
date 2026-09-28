CREATE POLICY "Users can only update their own sessions"
ON sessions
FOR UPDATE
USING (auth.uid() = user_id);