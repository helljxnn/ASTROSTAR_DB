use("astrostar");

// ==============================
// Tablas atómicas
// ==============================

db.createCollection("permissions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        permission: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("roles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        name: { bsonType: "string" },
        description: { bsonType: "string" },
        status: { bsonType: "bool" }
      }
    }
  }
});

db.createCollection("modules", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        module_name: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("document_types", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        name: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("sports_material", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        name: { bsonType: "string" },
        quantity: { bsonType: "int" },
        description: { bsonType: "string" },
        status: { bsonType: "bool" },
        type: { bsonType: "string" } // Comprado | Donado
      }
    }
  }
});

db.createCollection("sports_categories", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        name: { bsonType: "string" },
        min_age: { bsonType: "int" },
        max_age: { bsonType: "int" },
        details: { bsonType: "string" },
        url: { bsonType: "string" },
        status: { bsonType: "bool" }
      }
    }
  }
});

db.createCollection("employee_types", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        name: { bsonType: "string" },
        description: { bsonType: "string" },
        status: { bsonType: "bool" }
      }
    }
  }
});

db.createCollection("programs", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        program_name: { bsonType: "string" },
        description: { bsonType: "string" },
        status: { bsonType: "bool" },
        url_image: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("service_types", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        service_type_name: { bsonType: "string" }
      }
    }
  }
});

// ==============================
// Tablas dependientes
// ==============================

db.createCollection("persons", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        first_name: { bsonType: "string" },
        last_name: { bsonType: "string" },
        identification: { bsonType: "string" },
        phone_number: { bsonType: "string" },
        email: { bsonType: "string" },
        is_sportsman: { bsonType: "bool" },
        id_document_type: { bsonType: "objectId" },
        id_guardian: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        first_name: { bsonType: "string" },
        identification: { bsonType: "string" },
        email: { bsonType: "string" },
        phone_number: { bsonType: "string" },
        password: { bsonType: "string" },
        status: { bsonType: "bool" },
        id_role: { bsonType: "objectId" },
        id_document_type: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("suppliers", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        company_name: { bsonType: "string" },
        tax_id: { bsonType: "string" },
        first_name: { bsonType: "string" },
        identification_number: { bsonType: "string" },
        contact_name: { bsonType: "string" },
        contact_phone: { bsonType: "string" },
        contact_email: { bsonType: "string" },
        address: { bsonType: "string" },
        description: { bsonType: "string" },
        status: { bsonType: "bool" },
        entity_type: { bsonType: "string" },
        id_document_type: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("purchases", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        invoice_number: { bsonType: "string" },
        purchase_date: { bsonType: "date" },
        total: { bsonType: "double" },
        id_supplier: { bsonType: "objectId" },
        status: { bsonType: "bool" }
      }
    }
  }
});

db.createCollection("purchase_details", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        quantity: { bsonType: "int" },
        unit_price: { bsonType: "double" },
        subtotal: { bsonType: "double" },
        id_purchase: { bsonType: "objectId" },
        id_sports_material: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("employees", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_user: { bsonType: "objectId" },
        id_employee_type: { bsonType: "objectId" },
        age: { bsonType: "int" },
        status: { bsonType: "bool" },
        status_date: { bsonType: "date" }
      }
    }
  }
});

db.createCollection("employee_schedules", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_employee: { bsonType: "objectId" },
        schedule_date: { bsonType: "date" },
        start_time: { bsonType: "string" },
        end_time: { bsonType: "string" },
        description: { bsonType: "string" },
        status: { bsonType: "string" },
        cancellation_reason: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("donor_sponsors", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        social_reason: { bsonType: "string" },
        tax_id: { bsonType: "string" },
        contact_person: { bsonType: "string" },
        phone: { bsonType: "string" },
        email: { bsonType: "string" },
        type: { bsonType: "string" },
        status: { bsonType: "bool" },
        id_document_type: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("donations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_donor_sponsor: { bsonType: "objectId" },
        quantity: { bsonType: "int" },
        description: { bsonType: "string" },
        status: { bsonType: "bool" },
        donation_type: { bsonType: "string" },
        donation_date: { bsonType: "date" },
        registration_date: { bsonType: "date" }
      }
    }
  }
});

db.createCollection("donation_details", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_donation: { bsonType: "objectId" },
        id_sports_material: { bsonType: "objectId" },
        description: { bsonType: "string" },
        quantity: { bsonType: "int" },
        status: { bsonType: "bool" },
        observation: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("sportsmen", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_person: { bsonType: "objectId" },
        id_sports_category: { bsonType: "objectId" },
        age: { bsonType: "int" }
      }
    }
  }
});

db.createCollection("appointments", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        appointment_datetime: { bsonType: "date" },
        title: { bsonType: "string" },
        description: { bsonType: "string" },
        status: { bsonType: "string" },
        concept: { bsonType: "string" },
        id_sportsman: { bsonType: "objectId" },
        id_employee: { bsonType: "objectId" },
        id_program: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("services", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_service_type: { bsonType: "objectId" },
        service_name: { bsonType: "string" },
        service_description: { bsonType: "string" },
        start_date: { bsonType: "date" },
        end_date: { bsonType: "date" },
        location: { bsonType: "string" },
        contact_phone: { bsonType: "string" },
        url_image: { bsonType: "string" },
        service_status: { bsonType: "string" },
        service_details: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("temp_persons", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        person_type: { bsonType: "string" },
        name: { bsonType: "string" },
        id_document_type: { bsonType: "objectId" },
        identification: { bsonType: "string" },
        age: { bsonType: "int" },
        phone_number: { bsonType: "string" },
        birth_date: { bsonType: "date" },
        id_sports_category: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("teams", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        team_name: { bsonType: "string" },
        id_sports_category: { bsonType: "objectId" }
      }
    }
  }
});

// ==============================
// Tablas puente (N:M)
// ==============================

db.createCollection("role_permissions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_role: { bsonType: "objectId" },
        id_permission: { bsonType: "objectId" },
        id_module: { bsonType: "objectId" }
      }
    }
  }
});

db.createCollection("service_registrations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_person: { bsonType: "objectId" },
        id_temp_person: { bsonType: "objectId" },
        id_service: { bsonType: "objectId" },
        registration_date: { bsonType: "date" },
        registration_status: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("sponsors_services", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_service: { bsonType: "objectId" },
        id_donor_sponsor: { bsonType: "objectId" },
        sponsorship_description: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("team_members", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_team: { bsonType: "objectId" },
        id_person: { bsonType: "objectId" },
        id_temp_person: { bsonType: "objectId" },
        role_in_team: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("team_registrations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      properties: {
        id_team: { bsonType: "objectId" },
        id_service: { bsonType: "objectId" },
        registration_date: { bsonType: "date" },
        registration_status: { bsonType: "string" }
      }
    }
  }
});
