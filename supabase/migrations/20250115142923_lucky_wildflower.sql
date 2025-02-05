/*
  # Update receipt template with better structure

  1. Changes
    - Add business details section in header
    - Improve customer information layout
    - Add proper items table structure
    - Add payment details section
    - Add footer with legal text

  2. Template Sections
    - Header: Business logo, name, and contact details
    - Customer Info: Name, phone, address
    - Items Table: Product details with proper columns
    - Payment Info: Total amount and payment method
    - Footer: Thank you message and legal text
*/

-- Update document_templates table with new receipt template
UPDATE document_templates
SET content = '{
  "header": {
    "logo": {
      "enabled": true,
      "size": "150px",
      "alignment": "center"
    },
    "businessDetails": {
      "enabled": true,
      "fontSize": "16px",
      "alignment": "center",
      "fields": {
        "name": { "enabled": true, "fontSize": "24px", "fontWeight": "bold" },
        "vatNumber": { "enabled": true, "fontSize": "14px" },
        "phone": { "enabled": true, "fontSize": "14px" },
        "email": { "enabled": true, "fontSize": "14px" }
      }
    },
    "title": {
      "text": "קבלה",
      "fontSize": "28px",
      "fontWeight": "bold",
      "alignment": "center",
      "margin": "20px 0"
    },
    "receiptNumber": {
      "enabled": true,
      "fontSize": "16px",
      "alignment": "center"
    },
    "date": {
      "enabled": true,
      "fontSize": "16px",
      "alignment": "center"
    }
  },
  "customerDetails": {
    "enabled": true,
    "title": {
      "text": "פרטי לקוח",
      "fontSize": "18px",
      "fontWeight": "bold"
    },
    "fields": {
      "name": {
        "enabled": true,
        "label": "שם",
        "fontSize": "16px"
      },
      "phone": {
        "enabled": true,
        "label": "טלפון",
        "fontSize": "16px"
      }
    },
    "style": {
      "border": "1px solid #eee",
      "borderRadius": "8px",
      "padding": "15px",
      "margin": "20px 0"
    }
  },
  "itemsTable": {
    "enabled": true,
    "style": {
      "width": "100%",
      "borderCollapse": "collapse",
      "margin": "20px 0"
    },
    "header": {
      "fontSize": "16px",
      "fontWeight": "bold",
      "backgroundColor": "#f8f9fa",
      "color": "#333"
    },
    "columns": [
      {
        "id": "name",
        "header": "פריט",
        "width": "40%",
        "alignment": "right"
      },
      {
        "id": "quantity",
        "header": "כמות",
        "width": "15%",
        "alignment": "center"
      },
      {
        "id": "price",
        "header": "מחיר",
        "width": "20%",
        "alignment": "left"
      },
      {
        "id": "total",
        "header": "סה״כ",
        "width": "25%",
        "alignment": "left"
      }
    ],
    "rows": {
      "fontSize": "14px",
      "padding": "10px",
      "borderBottom": "1px solid #eee"
    }
  },
  "paymentDetails": {
    "enabled": true,
    "style": {
      "margin": "20px 0",
      "padding": "15px",
      "borderTop": "2px solid #eee"
    },
    "total": {
      "fontSize": "20px",
      "fontWeight": "bold",
      "alignment": "left"
    },
    "method": {
      "fontSize": "16px",
      "color": "#666"
    }
  },
  "footer": {
    "enabled": true,
    "style": {
      "textAlign": "center",
      "marginTop": "40px",
      "borderTop": "1px solid #eee",
      "paddingTop": "20px"
    },
    "thankYou": {
      "enabled": true,
      "text": "תודה על קנייתך!",
      "fontSize": "16px",
      "margin": "10px 0"
    },
    "legalText": {
      "enabled": true,
      "text": "למוסד אישור מס הכנסה לענין תרומות לפי סעיף 46 לפקודה",
      "fontSize": "14px",
      "color": "#666"
    }
  }
}'::jsonb
WHERE type = 'receipt'
AND name = 'קבלה סטנדרטית';

-- Insert template if it doesn't exist
INSERT INTO document_templates (name, type, content, is_default)
SELECT 
  'קבלה סטנדרטית',
  'receipt',
  '{
    "header": {
      "logo": {
        "enabled": true,
        "size": "150px",
        "alignment": "center"
      },
      "businessDetails": {
        "enabled": true,
        "fontSize": "16px",
        "alignment": "center",
        "fields": {
          "name": { "enabled": true, "fontSize": "24px", "fontWeight": "bold" },
          "vatNumber": { "enabled": true, "fontSize": "14px" },
          "phone": { "enabled": true, "fontSize": "14px" },
          "email": { "enabled": true, "fontSize": "14px" }
        }
      },
      "title": {
        "text": "קבלה",
        "fontSize": "28px",
        "fontWeight": "bold",
        "alignment": "center",
        "margin": "20px 0"
      },
      "receiptNumber": {
        "enabled": true,
        "fontSize": "16px",
        "alignment": "center"
      },
      "date": {
        "enabled": true,
        "fontSize": "16px",
        "alignment": "center"
      }
    },
    "customerDetails": {
      "enabled": true,
      "title": {
        "text": "פרטי לקוח",
        "fontSize": "18px",
        "fontWeight": "bold"
      },
      "fields": {
        "name": {
          "enabled": true,
          "label": "שם",
          "fontSize": "16px"
        },
        "phone": {
          "enabled": true,
          "label": "טלפון",
          "fontSize": "16px"
        }
      },
      "style": {
        "border": "1px solid #eee",
        "borderRadius": "8px",
        "padding": "15px",
        "margin": "20px 0"
      }
    },
    "itemsTable": {
      "enabled": true,
      "style": {
        "width": "100%",
        "borderCollapse": "collapse",
        "margin": "20px 0"
      },
      "header": {
        "fontSize": "16px",
        "fontWeight": "bold",
        "backgroundColor": "#f8f9fa",
        "color": "#333"
      },
      "columns": [
        {
          "id": "name",
          "header": "פריט",
          "width": "40%",
          "alignment": "right"
        },
        {
          "id": "quantity",
          "header": "כמות",
          "width": "15%",
          "alignment": "center"
        },
        {
          "id": "price",
          "header": "מחיר",
          "width": "20%",
          "alignment": "left"
        },
        {
          "id": "total",
          "header": "סה״כ",
          "width": "25%",
          "alignment": "left"
        }
      ],
      "rows": {
        "fontSize": "14px",
        "padding": "10px",
        "borderBottom": "1px solid #eee"
      }
    },
    "paymentDetails": {
      "enabled": true,
      "style": {
        "margin": "20px 0",
        "padding": "15px",
        "borderTop": "2px solid #eee"
      },
      "total": {
        "fontSize": "20px",
        "fontWeight": "bold",
        "alignment": "left"
      },
      "method": {
        "fontSize": "16px",
        "color": "#666"
      }
    },
    "footer": {
      "enabled": true,
      "style": {
        "textAlign": "center",
        "marginTop": "40px",
        "borderTop": "1px solid #eee",
        "paddingTop": "20px"
      },
      "thankYou": {
        "enabled": true,
        "text": "תודה על קנייתך!",
        "fontSize": "16px",
        "margin": "10px 0"
      },
      "legalText": {
        "enabled": true,
        "text": "למוסד אישור מס הכנסה לענין תרומות לפי סעיף 46 לפקודה",
        "fontSize": "14px",
        "color": "#666"
      }
    }
  }'::jsonb,
  true
WHERE NOT EXISTS (
  SELECT 1 FROM document_templates 
  WHERE type = 'receipt' 
  AND name = 'קבלה סטנדרטית'
);