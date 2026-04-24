-- ═══════════════════════════════════════════════════
-- Supabase Setup: Assignment Submission
-- Run this in Supabase SQL Editor (Dashboard > SQL)
-- ═══════════════════════════════════════════════════

-- 1. Create submissions table
CREATE TABLE IF NOT EXISTS submissions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_url TEXT,
    file_size BIGINT,
    week INTEGER,
    assignment_type TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1a. If the table already exists from a previous run, add the new column
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS assignment_type TEXT;
ALTER TABLE submissions ALTER COLUMN week DROP NOT NULL;

-- 2. Enable Row Level Security
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- 3. Allow anonymous inserts (for student submissions)
CREATE POLICY "Allow anonymous insert" ON submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- 4. Allow anonymous select (optional: for confirmation)
CREATE POLICY "Allow anonymous select own" ON submissions
    FOR SELECT
    TO anon
    USING (true);

-- 5. Create storage bucket for assignments
INSERT INTO storage.buckets (id, name, public)
VALUES ('assignments', 'assignments', true)
ON CONFLICT (id) DO NOTHING;

-- 6. Allow anonymous uploads to assignments bucket
CREATE POLICY "Allow anonymous upload" ON storage.objects
    FOR INSERT
    TO anon
    WITH CHECK (bucket_id = 'assignments');

-- 7. Allow public read access to uploaded files
CREATE POLICY "Allow public read" ON storage.objects
    FOR SELECT
    TO anon
    USING (bucket_id = 'assignments');
