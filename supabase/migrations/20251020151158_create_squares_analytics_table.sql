/*
  # Squares Analytics Table

  ## Overview
  Track user interactions with the animated Squares background component for engagement analytics.

  ## New Tables

  ### `squares_interactions`
  - `id` (uuid, primary key) - Unique interaction identifier
  - `user_id` (uuid, nullable, foreign key) - Reference to auth.users (nullable for anonymous users)
  - `page_section` (text) - Which section of the site (hero, explore, admin, loading)
  - `interaction_type` (text) - Type of interaction (hover, view)
  - `duration_seconds` (integer) - How long the user interacted
  - `square_count` (integer) - Number of squares hovered over
  - `created_at` (timestamptz) - Timestamp of interaction

  ## Security
  - Enable RLS on squares_interactions table
  - Anyone can insert interactions (for anonymous tracking)
  - Users can view their own interactions
  - Admins can view all interactions

  ## Important Notes
  1. RLS allows anonymous inserts for analytics
  2. Tracks engagement metrics for UI optimization
  3. Indexed for performance on common queries
*/

-- Create squares_interactions table
CREATE TABLE IF NOT EXISTS squares_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  page_section text NOT NULL CHECK (page_section IN ('hero', 'explore', 'admin', 'loading')),
  interaction_type text NOT NULL CHECK (interaction_type IN ('hover', 'view')),
  duration_seconds integer DEFAULT 0,
  square_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE squares_interactions ENABLE ROW LEVEL SECURITY;

-- Squares interactions policies
CREATE POLICY "Anyone can insert interactions"
  ON squares_interactions FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can view own interactions"
  ON squares_interactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all interactions"
  ON squares_interactions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_squares_interactions_user_id ON squares_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_squares_interactions_page_section ON squares_interactions(page_section);
CREATE INDEX IF NOT EXISTS idx_squares_interactions_created_at ON squares_interactions(created_at DESC);