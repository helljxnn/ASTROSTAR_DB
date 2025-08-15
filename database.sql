-- Create Database
CREATE DATABASE astrostar;
USE astrostar;

-- Permisos
CREATE TABLE permissions (
    id_permission SERIAL PRIMARY KEY, 
    permission VARCHAR(20)NOT NULL,
    -- Define the unique constraint with an explicit name.
    CONSTRAINT UNQ_permissions_permission UNIQUE (permission)
);

-- roles
CREATE TABLE roles (
    id_rol SERIAL,
    name VARCHAR(20) NOT NULL,
    description TEXT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_roles PRIMARY KEY (id_rol),
    -- Define la restrincción unica con un nombre unico.
    CONSTRAINT UNQ_roles_name UNIQUE (name)
);

-- Modulos
CREATE TABLE modules (
    id_module SERIAL,
    module_name VARCHAR(20) NOT NULL,
    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_modules PRIMARY KEY (id_module),
    -- Define la restricción de unicidad con un nombre.
    CONSTRAINT UNQ_modules_module_name UNIQUE (module_name)
);

-- Tipo de documento
CREATE TABLE documentType(
    -- Define for autoincremental.
    id_documentType INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    -- Defin the primary key with an explicit name.
    CONSTRAINT PK_documentType PRIMARY KEY (id_documentType),
    -- Define the unique constraint with an explicit name.
    CONSTRAINT UNQ_documentType_name UNIQUE (name)
) 

-- Tabla puente -> roles y modulos
CREATE TABLE role_permissions (
    id_role_permission SERIAL,
    id_role INTEGER NOT NULL,
    id_permission INTEGER NOT NULL,
    id_module INTEGER NOT NULL,
    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_role_permissions PRIMARY KEY (id_role_permission),

    -- Define la restricción de unicidad para evitar duplicados.
    CONSTRAINT UNQ_role_permissions_role_module_permission UNIQUE (id_role, id_module, id_permission),

    -- Llave foránea que referencia a la tabla 'roles'.
    CONSTRAINT FK_role_permissions_roles
        FOREIGN KEY (id_role)
        REFERENCES roles(id_role)
        ON DELETE CASCADE,

    -- Llave foránea que referencia a la tabla 'permissions'.
    CONSTRAINT FK_role_permissions_permissions
        FOREIGN KEY (id_permission)
        REFERENCES permissions(id_permission)
        ON DELETE CASCADE,

    -- Llave foránea que referencia a la tabla 'modules'.
    CONSTRAINT FK_role_permissions_modules
        FOREIGN KEY (id_module)
        REFERENCES modules(id_module)
        ON DELETE CASCADE
);

-- Personas
CREATE TABLE persons (
    id_person SERIAL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    identification VARCHAR(15) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(50) NOT NULL,
    is_sportsman BOOLEAN NOT NULL,
    id_document_type INT NOT NULL,
    id_guardian INTEGER, -- Referencia a la misma tabla 'persons'

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_persons PRIMARY KEY (id_person),
    
    -- Restricciones de unicidad para la identificación y el correo.
    CONSTRAINT UNQ_persons_identification UNIQUE (identification),
    CONSTRAINT UNQ_persons_email UNIQUE (email),
    
    -- Llave foránea que referencia a la tabla 'document_types'.
    CONSTRAINT FK_persons_document_types
        FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type)
        ON DELETE RESTRICT,
        
    -- Llave foránea para el acudiente (referencia a la misma tabla 'persons').
    -- Este campo puede ser nulo si la persona no es un deportista.
    CONSTRAINT FK_persons_guardian
        FOREIGN KEY (id_guardian)
        REFERENCES persons(id_person)
        ON DELETE SET NULL
);

-- Usuarios
CREATE TABLE users (
    id_user SERIAL,
    first_name VARCHAR(30) NOT NULL,
    identification VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    password VARCHAR(50) NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    id_role INTEGER NOT NULL,
    id_document_type INTEGER NOT NULL,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_users PRIMARY KEY (id_user),
    -- Restricciones de unicidad para la identificación y el correo.
    CONSTRAINT UNQ_users_identification UNIQUE (identification),
    CONSTRAINT UNQ_users_email UNIQUE (email),

    -- Llave foránea que referencia a la tabla 'roles'.
    CONSTRAINT FK_users_roles
        FOREIGN KEY (id_role)
        REFERENCES roles(id_role)
        ON DELETE RESTRICT,
    -- Llave foránea que referencia a la tabla 'document_types'.
    CONSTRAINT FK_users_document_types
        FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type)
        ON DELETE RESTRICT
);


-- Creamos el tipo de dato ENUM para el campo 'type'
CREATE TYPE material_type AS ENUM ('Comprado', 'Donado');

-- 7. Tabla 'sports_material'
-- Tabla de control de existencia de productos de material deportivo.
CREATE TABLE sports_material (
    id_sports_material SERIAL,
    name VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    description TEXT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    type material_type NOT NULL,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_sports_material PRIMARY KEY (id_sports_material)
);

-- Creamos el tipo de dato ENUM para el campo 'type' de la tabla de proveedores
CREATE TYPE entity_type AS ENUM ('juridica', 'natural');

-- Tabla de gestión de proveedores.
CREATE TABLE suppliers (
    id_supplier SERIAL,
    company_name VARCHAR(100),
    tax_id VARCHAR(100),
    first_name VARCHAR(100),
    identification_number VARCHAR(100),
    contact_name VARCHAR(50),
    contact_phone VARCHAR(25),
    contact_email VARCHAR(100),
    address VARCHAR(150),
    description TEXT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    entity_type entity_type NOT NULL,
    id_document_type INT, -- Este campo es opcional si el tipo de entidad es 'juridica'

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_suppliers PRIMARY KEY (id_supplier),
    -- Restricciones de unicidad para el tax_id y el identification_number
    CONSTRAINT UNQ_suppliers_tax_id UNIQUE (tax_id),
    CONSTRAINT UNQ_suppliers_identification_number UNIQUE (identification_number),
    
    -- La llave foránea para el tipo de documento solo se usa si es un proveedor natural.
    CONSTRAINT FK_suppliers_document_types
        FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type)
        ON DELETE RESTRICT,
        
    -- Constraint CHECK para asegurar que 'company_name' o 'first_name' no sean nulos.
    CONSTRAINT CHK_suppliers_name CHECK (
        (entity_type = 'juridica' AND company_name IS NOT NULL AND first_name IS NULL) OR
        (entity_type = 'natural' AND first_name IS NOT NULL AND company_name IS NULL)
    ),

    -- Constraint CHECK para asegurar que 'tax_id' o 'identification_number' no sean nulos.
    CONSTRAINT CHK_suppliers_id CHECK (
        (entity_type = 'juridica' AND tax_id IS NOT NULL AND identification_number IS NULL) OR
        (entity_type = 'natural' AND identification_number IS NOT NULL AND tax_id IS NULL)
    )
);

-- Tabla de compras.
CREATE TABLE purchases (
    id_purchase SERIAL,
    invoice_number VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    id_supplier INTEGER NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_purchases PRIMARY KEY (id_purchase),
    -- Restricción de unicidad para el número de factura.
    CONSTRAINT UNQ_purchases_invoice_number UNIQUE (invoice_number),
    
    -- Llave foránea que referencia a la tabla 'suppliers'.
    CONSTRAINT FK_purchases_suppliers
        FOREIGN KEY (id_supplier)
        REFERENCES suppliers(id_supplier)
        ON DELETE RESTRICT
);

-- Tabla de detalles de compra.
CREATE TABLE purchase_details (
    id_purchase_detail SERIAL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    id_purchase INTEGER NOT NULL,
    id_sports_material INTEGER NOT NULL,
    
    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_purchase_details PRIMARY KEY (id_purchase_detail),
    
    -- Restricción de unicidad para evitar duplicados en el detalle de la compra.
    CONSTRAINT UNQ_purchase_details UNIQUE (id_purchase, id_sports_material),
    
    -- Llave foránea que referencia a la tabla 'purchases'.
    CONSTRAINT FK_purchase_details_purchases
        FOREIGN KEY (id_purchase)
        REFERENCES purchases(id_purchase)
        ON DELETE CASCADE,
    -- Llave foránea que referencia a la tabla 'sports_material'.
    CONSTRAINT FK_purchase_details_sports_material
        FOREIGN KEY (id_sports_material)
        REFERENCES sports_material(id_sports_material)
        ON DELETE CASCADE
);

-- Tabla de categorias deportivas
CREATE TABLE sports_categories (
    id_sports_category SERIAL,
    name VARCHAR(20) NOT NULL,
    min_age INT NOT NULL,
    max_age INT NOT NULL,
    details VARCHAR, 
    url VARCHAR(60),
    status BOOLEAN NOT NULL DEFAULT TRUE,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_sports_categories PRIMARY KEY (id_sports_category),
    -- Define la restricción de unicidad para el nombre de la categoría.
    CONSTRAINT UNQ_sports_categories_name UNIQUE (name),
    -- Verifica que la edad mínima sea menor que la máxima.
    CONSTRAINT CHK_sports_categories_age CHECK (min_age < max_age)
);

-- Tipos de empleado
CREATE TABLE employee_types (
    id_employee_type SERIAL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_employee_types PRIMARY KEY (id_employee_type),
    -- Restricción de unicidad para el nombre del tipo de empleado.
    CONSTRAINT UNQ_employee_types_name UNIQUE (name)
);

-- Empleados
CREATE TABLE employees (
    id_employee SERIAL,
    id_user INTEGER NOT NULL,
    id_employee_type INTEGER NOT NULL,
    age INT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    status_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_employees PRIMARY KEY (id_employee),
    
    -- Restricción de unicidad para el id de usuario para asegurar que cada usuario es un empleado.
    CONSTRAINT UNQ_employees_user_id UNIQUE (id_user),

    -- Llave foránea que referencia a la tabla 'users'.
    CONSTRAINT FK_employees_users
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE RESTRICT,
    
    -- Llave foránea que referencia a la tabla 'employee_types'.
    CONSTRAINT FK_employees_employee_types
        FOREIGN KEY (id_employee_type)
        REFERENCES employee_types(id_employee_type)
        ON DELETE RESTRICT
);

-- Tipo de dato ENUM para el estado del horario
CREATE TYPE schedule_status AS ENUM ('Programado', 'Ejecutado', 'Cancelado');

-- Programación de horarios de empleados
CREATE TABLE employee_schedules (
    id_employee_schedule SERIAL,
    id_employee INTEGER NOT NULL,
    schedule_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description VARCHAR(255),
    status schedule_status NOT NULL,
    cancellation_reason VARCHAR(255),

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_employee_schedules PRIMARY KEY (id_employee_schedule),
    
    -- Llave foránea que referencia a la tabla 'employees'.
    CONSTRAINT FK_employee_schedules_employees
        FOREIGN KEY (id_employee)
        REFERENCES employees(id_employee)
        ON DELETE CASCADE
);


-- Tipo de dato ENUM para el tipo de donante/patrocinador
CREATE TYPE donor_sponsor_type AS ENUM ('Patrocinador', 'Donante');

-- Donantes/patrocinadores
CREATE TABLE donor_sponsors (
    id_donor_sponsor SERIAL,
    social_reason VARCHAR(20) NOT NULL,
    tax_id VARCHAR(20) NOT NULL,
    contact_person VARCHAR(50),
    phone VARCHAR(10),
    email VARCHAR(100),
    type donor_sponsor_type NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    id_document_type INT NOT NULL,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_donor_sponsors PRIMARY KEY (id_donor_sponsor),

    -- Restricciones de unicidad para el tax_id.
    CONSTRAINT UNQ_donor_sponsors_tax_id UNIQUE (tax_id),

    -- Llave foránea que referencia a la tabla 'document_types'.
    CONSTRAINT FK_donor_sponsors_document_types
        FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type)
        ON DELETE RESTRIC
);

-- Tbala de donaciones 
CREATE TABLE donations (
    id_donation SERIAL,
    id_donor_sponsors INT NOT NULL, -- Llave foránea hacia donor_sponsors
    quantity INT NOT NULL,
    description TEXT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE, -- TRUE = Registrado, FALSE = Anulado
    donation_type VARCHAR(50) NOT NULL,
    donation_date DATE NOT NULL,
    registration_date DATE NOT NULL,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_donations PRIMARY KEY (id_donation),

    -- Llave foránea que referencia a la tabla 'donor_sponsors'.
    CONSTRAINT FK_donations_donor_sponsors
        FOREIGN KEY (id_donor_sponsors)
        REFERENCES donor_sponsors(id_donor_sponsors )
        ON DELETE RESTRICT
);


-- Tabla de detalles de donaciones
CREATE TABLE donation_details (
    id_donation_detail SERIAL,                      -- PK: Identificador único del detalle de donación
    id_donation INT NOT NULL,                       -- FK: Referencia a donations.id_donation
    id_sports_material INT NOT NULL,                -- FK: Referencia a sports_material.id_sports_material
    description VARCHAR(50) NOT NULL,               -- Descripción del artículo donado
    quantity INT NOT NULL CHECK (quantity > 0),     -- Cantidad (debe ser mayor que 0)
    status BOOLEAN NOT NULL,                        -- TRUE = Nuevo, FALSE = Usado
    observation VARCHAR(50),                        

    -- Clave primaria
    CONSTRAINT pk_donation_details PRIMARY KEY (id_donation_detail),

    -- Clave foránea hacia la tabla de donaciones (con eliminación en cascada)
    CONSTRAINT fk_donation_details_donations
        FOREIGN KEY (id_donation)
        REFERENCES donations(id_donation)
        ON DELETE CASCADE,

    -- Clave foránea hacia la tabla de material deportivo (sin eliminación en cascada)
    CONSTRAINT fk_donation_details_sports_material
        FOREIGN KEY (id_sports_material)    
        REFERENCES sports_material(id_sports_material)
        ON DELETE RESTRICT
);


-- Tabla 'programs'
CREATE TABLE programs (
    id_program SERIAL,
    program_name VARCHAR(30) NOT NULL,
    description TEXT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    url_image VARCHAR(60),

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_programs PRIMARY KEY (id_program),
    -- Restricción de unicidad para el nombre del programa.
    CONSTRAINT UNQ_programs_program_name UNIQUE (program_name)
);

-- Tabla 'sportsmen'
-- Tabla para identificar a los deportistas y relacionarlos con la categoria deportiva
CREATE TABLE sportsmen (
    id_sportsman SERIAL,
    id_person INTEGER NOT NULL,
    id_sports_category INTEGER NOT NULL,
    age INT,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_sportsmen PRIMARY KEY (id_sportsman),
    -- Restricción de unicidad para el id de la persona.
    CONSTRAINT UNQ_sportsmen_id_person UNIQUE (id_person),

    -- Llave foránea que referencia a la tabla 'persons'.
    CONSTRAINT FK_sportsmen_persons
        FOREIGN KEY (id_person)
        REFERENCES persons(id_person)
        ON DELETE RESTRICT,
    -- Llave foránea que referencia a la tabla 'sports_categories'.
    CONSTRAINT FK_sportsmen_sports_categories
        FOREIGN KEY (id_sports_category)
        REFERENCES sports_categories(id_sports_category)
        ON DELETE RESTRICT
);

-- Tabla 'appointments'
-- Tabla para la gestión de citas de los deportistas con los empleados.
CREATE TABLE appointments (
    id_appointment SERIAL,
    appointment_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL, -- Estado de la cita (e.g., 'Programada', 'Cancelada')
    concept TEXT, -- Motivo de cancelación o resultado de la cita
    id_sportsman INTEGER NOT NULL,
    id_employee INTEGER NOT NULL,
    id_program INTEGER NOT NULL,

    -- Define la llave primaria con un nombre explícito.
    CONSTRAINT PK_appointments PRIMARY KEY (id_appointment),

    -- Llave foránea que referencia a la tabla 'sportsmen'.
    CONSTRAINT FK_appointments_sportsmen
        FOREIGN KEY (id_sportsman)
        REFERENCES sportsmen(id_sportsman)
        ON DELETE RESTRICT,
    -- Llave foránea que referencia a la tabla 'employees'.
    CONSTRAINT FK_appointments_employees
        FOREIGN KEY (id_employee)
        REFERENCES employees(id_employee)
        ON DELETE RESTRICT,
    -- Llave foránea que referencia a la tabla 'programs'.
    CONSTRAINT FK_appointments_programs
        FOREIGN KEY (id_program)
        REFERENCES programs(id_program)
        ON DELETE RESTRICT,
    
    -- Restricción para validar los estados de la cita.
    CONSTRAINT CHK_appointments_status CHECK (status IN ('Programada', 'Cancelada', 'Ejecutada'))
);

-- Tabla para los tipos de servicio.
CREATE TABLE service_types (
    id_service_type SERIAL,
    service_type_name VARCHAR(20) NOT NULL,

    CONSTRAINT PK_service_types PRIMARY KEY (id_service_type),
    CONSTRAINT UNQ_service_types_name UNIQUE (service_type_name)
);

-- Tabla para la gestión de servicios.
CREATE TABLE services (
    id_service SERIAL,
    id_service_type INTEGER NOT NULL,
    service_name VARCHAR(80) NOT NULL,
    service_description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(80),
    url_image VARCHAR(80),
    service_status VARCHAR(80) NOT NULL,
    service_details TEXT,

    CONSTRAINT PK_services PRIMARY KEY (id_service),
    
    CONSTRAINT FK_services_service_types
        FOREIGN KEY (id_service_type)
        REFERENCES service_types(id_service_type)
        ON DELETE RESTRICT
);

-- Tabla de personas temporales
CREATE TABLE temp_persons (
    id_temp_person SERIAL, -- Identificador único de la persona temporal
    person_type VARCHAR(30), -- Tipo de persona (ej. jugador, entrenador)
    name VARCHAR(100), -- Nombre completo
    id_document_type INT, -- Tipo de documento (FK)
    identification VARCHAR(15), -- Número de identificación
    age INT, -- Edad de la persona
    phone_number VARCHAR(20), -- Número telefónico
    birth_date DATE, -- Fecha de nacimiento
    id_sport_category INT, -- Categoría deportiva (FK)
    CONSTRAINT PK_temp_persons_id_temp_person PRIMARY KEY (id_temp_person),
    CONSTRAINT FK_temp_persons_id_document_type FOREIGN KEY (id_document_type) REFERENCES document_types(id_document_type),
    CONSTRAINT FK_temp_persons_id_sport_category FOREIGN KEY (id_sport_category) REFERENCES sport_categories(id_sport_category)
);

-- Tabla de inscripciones a servicios

CREATE TABLE service_registrations (
    id_service_registration SERIAL, -- Identificador único de la inscripción
    id_person INT, -- Identificador de la persona (FK)
    id_temp_person INT, -- Identificador de la persona temporal (FK)
    id_service INT, -- Identificador del servicio (FK)
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de inscripción
    registration_status VARCHAR(50), -- Estado de la inscripción
    CONSTRAINT PK_service_registrations_id_service_registration PRIMARY KEY (id_service_registration),
    CONSTRAINT UNQ_service_registrations_id_person UNIQUE (id_person),
    CONSTRAINT UNQ_service_registrations_id_service UNIQUE (id_service),
    CONSTRAINT FK_service_registrations_id_person FOREIGN KEY (id_person) REFERENCES persons(id_person),
    CONSTRAINT FK_service_registrations_id_temp_person FOREIGN KEY (id_temp_person) REFERENCES temp_persons(id_temp_person),
    CONSTRAINT FK_service_registrations_id_service FOREIGN KEY (id_service) REFERENCES services(id_service)
);

-- Tabla que relaciona patrocinadores/donantes con los servicios
CREATE TABLE sponsors_services (
    id_sponsor_service SERIAL, -- Identificador único del patrocinio
    id_service INT, -- Identificador del servicio (FK)
    id_donor_sponsor INT, -- Identificador del donante o patrocinador (FK)
    sponsorship_description VARCHAR, -- Descripción del patrocinio
    CONSTRAINT PK_sponsors_services_id_sponsor_service PRIMARY KEY (id_sponsor_service),
    CONSTRAINT FK_sponsors_services_id_service FOREIGN KEY (id_service) REFERENCES services(id_service),
    CONSTRAINT FK_sponsors_services_id_donor_sponsor FOREIGN KEY (id_donor_sponsor) REFERENCES donors_sponsors(id_donor_sponsor)
);

-- Tabla de equipos

CREATE TABLE teams (
    id_team SERIAL, -- Identificador único del equipo
    team_name VARCHAR(100), -- Nombre del equipo
    id_sport_category INT, -- Categoría deportiva (FK)
    CONSTRAINT PK_teams_id_team PRIMARY KEY (id_team),
    CONSTRAINT FK_teams_id_sport_category FOREIGN KEY (id_sport_category) REFERENCES sport_categories(id_sport_category)
);


-- Tabla de miembros de equipo

CREATE TABLE team_members (
    id_team_member SERIAL, -- Identificador único del miembro del equipo
    id_team INT, -- Identificador del equipo (FK)
    id_person INT, -- Identificador de la persona (FK)
    id_temp_person INT, -- Identificador de la persona temporal (FK)
    role_in_team VARCHAR(50), -- Rol del miembro en el equipo
    CONSTRAINT PK_team_members_id_team_member PRIMARY KEY (id_team_member),
    CONSTRAINT FK_team_members_id_team FOREIGN KEY (id_team) REFERENCES teams(id_team),
    CONSTRAINT FK_team_members_id_person FOREIGN KEY (id_person) REFERENCES persons(id_person),
    CONSTRAINT FK_team_members_id_temp_person FOREIGN KEY (id_temp_person) REFERENCES temp_persons(id_temp_person)
);

-- Tabla de inscripción de equipos
CREATE TABLE team_registrations (
    id_team_registration SERIAL, -- Identificador único de la inscripción de equipo
    id_team INT, -- Identificador del equipo (FK)
    id_service INT, -- Identificador del servicio (FK)
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de inscripción
    registration_status VARCHAR(50), -- Estado de la inscripción
    CONSTRAINT PK_team_registrations_id_team_registration PRIMARY KEY (id_team_registration),
    CONSTRAINT FK_team_registrations_id_team FOREIGN KEY (id_team) REFERENCES teams(id_team),
    CONSTRAINT FK_team_registrations_id_service FOREIGN KEY (id_service) REFERENCES services(id_service)
);

