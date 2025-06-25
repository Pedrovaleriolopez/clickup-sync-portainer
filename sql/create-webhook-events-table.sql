-- Create webhook_events table for storing ClickUp webhook data
CREATE TABLE IF NOT EXISTS public.webhook_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_type VARCHAR(255),
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_webhook_events_created_at ON public.webhook_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_webhook_events_event_type ON public.webhook_events(event_type);
CREATE INDEX IF NOT EXISTS idx_webhook_events_processed ON public.webhook_events(processed);

-- Add RLS (Row Level Security) - Optional but recommended
ALTER TABLE public.webhook_events ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows the service to insert and select
CREATE POLICY "Enable insert for service" ON public.webhook_events
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Enable select for service" ON public.webhook_events
    FOR SELECT
    USING (true);

-- Add comment to table
COMMENT ON TABLE public.webhook_events IS 'Stores incoming webhook events from ClickUp';
