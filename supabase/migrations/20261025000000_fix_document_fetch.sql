-- Fix for document fetching: Use LEFT JOIN instead of INNER JOIN for accounts
-- This ensures documents are returned even if the user profile (accounts table) is missing

-- =====================================================
-- FUNCTION TO GET DOCUMENTS WITH USER DATA
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_my_documents_with_users()
RETURNS TABLE (
    id uuid,
    user_id uuid,
    title text,
    content jsonb,
    is_public boolean,
    created_at timestamptz,
    updated_at timestamptz,
    user_name varchar(255),
    user_email varchar(320),
    user_picture_url varchar(1000),
    user_public_data jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Return documents owned by the user with account data
    -- Using LEFT JOIN to ensure documents are returned even if account data is missing
    RETURN QUERY
    SELECT
        d.id,
        d.user_id,
        d.title,
        d.content,
        d.is_public,
        d.created_at,
        d.updated_at,
        a.name AS user_name,
        a.email AS user_email,
        a.picture_url AS user_picture_url,
        a.public_data AS user_public_data
    FROM documents d
    LEFT JOIN accounts a ON d.user_id = a.id
    WHERE d.user_id = auth.uid()
    ORDER BY d.updated_at DESC;
END;
$$;

-- =====================================================
-- FUNCTION TO GET SHARED DOCUMENTS WITH USER DATA
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_shared_documents_with_users()
RETURNS TABLE (
    id uuid,
    user_id uuid,
    title text,
    content jsonb,
    is_public boolean,
    created_at timestamptz,
    updated_at timestamptz,
    access_level text,
    user_name varchar(255),
    user_email varchar(320),
    user_picture_url varchar(1000),
    user_public_data jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Return documents shared with the user with user account data
    -- Using LEFT JOIN to ensure documents are returned even if account data is missing
    RETURN QUERY
    SELECT
        d.id,
        d.user_id,
        d.title,
        d.content,
        d.is_public,
        d.created_at,
        d.updated_at,
        sd.access_level::text,
        a.name AS user_name,
        a.email AS user_email,
        a.picture_url AS user_picture_url,
        a.public_data AS user_public_data
    FROM documents d
    INNER JOIN shared_documents sd ON d.id = sd.document_id
    LEFT JOIN accounts a ON d.user_id = a.id
    WHERE sd.user_id = auth.uid()
    ORDER BY d.updated_at DESC;
END;
$$;

-- =====================================================
-- FUNCTION TO GET STARRED DOCUMENTS WITH USER DATA
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_starred_documents_with_users()
RETURNS TABLE (
    id uuid,
    user_id uuid,
    title text,
    content jsonb,
    is_public boolean,
    created_at timestamptz,
    updated_at timestamptz,
    starred_at timestamptz,
    user_name varchar(255),
    user_email varchar(320),
    user_picture_url varchar(1000),
    user_public_data jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Return starred documents with user account data
    -- Using LEFT JOIN to ensure documents are returned even if account data is missing
    RETURN QUERY
    SELECT
        d.id,
        d.user_id,
        d.title,
        d.content,
        d.is_public,
        d.created_at,
        d.updated_at,
        std.created_at AS starred_at,
        a.name AS user_name,
        a.email AS user_email,
        a.picture_url AS user_picture_url,
        a.public_data AS user_public_data
    FROM documents d
    INNER JOIN starred_documents std ON d.id = std.document_id
    LEFT JOIN accounts a ON d.user_id = a.id
    WHERE std.user_id = auth.uid()
    ORDER BY std.created_at DESC;
END;
$$;

-- =====================================================
-- FUNCTION TO GET TRASHED DOCUMENTS WITH USER DATA
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_trashed_documents_with_users()
RETURNS TABLE (
    id uuid,
    user_id uuid,
    title text,
    content jsonb,
    created_at timestamptz,
    updated_at timestamptz,
    trashed_at timestamptz,
    user_name varchar(255),
    user_email varchar(320),
    user_picture_url varchar(1000),
    user_public_data jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Return trashed documents with user account data
    -- Using LEFT JOIN to ensure documents are returned even if account data is missing
    RETURN QUERY
    SELECT
        td.id,
        td.user_id,
        td.title,
        td.content,
        td.created_at,
        td.updated_at,
        td.trashed_at,
        a.name AS user_name,
        a.email AS user_email,
        a.picture_url AS user_picture_url,
        a.public_data AS user_public_data
    FROM trashed_documents td
    LEFT JOIN accounts a ON td.user_id = a.id
    WHERE td.user_id = auth.uid()
    ORDER BY td.trashed_at DESC;
END;
$$;
