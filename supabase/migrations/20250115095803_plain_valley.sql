-- Create document_templates table
CREATE TABLE IF NOT EXISTS document_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  content jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE document_templates ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "document_templates_read_policy"
  ON document_templates FOR SELECT
  USING (true);

CREATE POLICY "document_templates_write_policy"
  ON document_templates
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Insert default receipt template
INSERT INTO document_templates (name, content)
VALUES (
  'receipt',
  '{
    "header": {
      "logo": {
        "enabled": true,
        "size": 30,
        "position": "right"
      },
      "title": {
        "text": "קבלה",
        "fontSize": 16,
        "alignment": "center"
      },
      "subtitle": {
        "text": "מספר: {receipt_number}",
        "fontSize": 12,
        "alignment": "center"
      }
    },
    "body": {
      "customerDetails": {
        "enabled": true,
        "fontSize": 12,
        "alignment": "right"
      },
      "itemsTable": {
        "enabled": true,
        "fontSize": 12,
        "columns": [
          {"name": "פריט", "enabled": true, "width": 40},
          {"name": "כמות", "enabled": true, "width": 15},
          {"name": "מחיר", "enabled": true, "width": 20},
          {"name": "סה\"כ", "enabled": true, "width": 25}
        ]
      }
    },
    "footer": {
      "note": {
        "enabled": true,
        "text": "תודה על קנייתך!",
        "fontSize": 10,
        "alignment": "center"
      },
      "signature": {
        "enabled": true,
        "text": "חתימה: ____________________",
        "fontSize": 10
      }
    }
  }'::jsonb
) ON CONFLICT (name) DO UPDATE
SET content = EXCLUDED.content;