-- ======================================================
-- CREATE DATABASE
-- ======================================================

CREATE DATABASE astrostar;
USE astrostar;

-- ======================================================
-- TABLAS ATÓMICAS (No dependen de ninguna otra)
-- ======================================================

-- Tipos ENUM
CREATE TYPE material_type AS ENUM ('Comprado', 'Donado');
CREATE TYPE entity_type AS ENUM ('juridica', 'natural');
CREATE TYPE schedule_status AS ENUM ('Programado', 'Ejecutado', 'Cancelado');
CREATE TYPE donor_sponsor_type AS ENUM ('Patrocinador', 'Donante');

-- Tabla de permisos
CREATE TABLE permissions (
    id_permission SERIAL,
    permission VARCHAR(20) NOT NULL,
    CONSTRAINT PK_permissions PRIMARY KEY (id_permission),
    CONSTRAINT UNQ_permissions_permission UNIQUE (permission)
);

-- Tabla de roles
CREATE TABLE roles (
    id_role SERIAL,
    name VARCHAR(20) NOT NULL,
    description TEXT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_roles PRIMARY KEY (id_role),
    CONSTRAINT UNQ_roles_name UNIQUE (name)
);

-- Tabla de módulos
CREATE TABLE modules (
    id_module SERIAL,
    module_name VARCHAR(20) NOT NULL,
    CONSTRAINT PK_modules PRIMARY KEY (id_module),
    CONSTRAINT UNQ_modules_module_name UNIQUE (module_name)
);

-- Tipos de documento
CREATE TABLE document_types (
    id_document_type SERIAL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT PK_document_types PRIMARY KEY (id_document_type),
    CONSTRAINT UNQ_document_types_name UNIQUE (name)
);

-- Material deportivo
CREATE TABLE sports_material (
    id_sports_material SERIAL,
    name VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    description TEXT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    type material_type NOT NULL,
    CONSTRAINT PK_sports_material PRIMARY KEY (id_sports_material)
);

-- Categorías deportivas
CREATE TABLE sports_categories (
    id_sports_category SERIAL,
    name VARCHAR(20) NOT NULL,
    min_age INT NOT NULL,
    max_age INT NOT NULL,
    details VARCHAR,
    url VARCHAR(60),
    status BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_sports_categories PRIMARY KEY (id_sports_category),
    CONSTRAINT UNQ_sports_categories_name UNIQUE (name),
    CONSTRAINT CHK_sports_categories_age CHECK (min_age < max_age)
);

-- Tipos de empleados
CREATE TABLE employee_types (
    id_employee_type SERIAL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_employee_types PRIMARY KEY (id_employee_type),
    CONSTRAINT UNQ_employee_types_name UNIQUE (name)
);

-- Programas
CREATE TABLE programs (
    id_program SERIAL,
    program_name VARCHAR(30) NOT NULL,
    description TEXT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    url_image VARCHAR(60),
    CONSTRAINT PK_programs PRIMARY KEY (id_program),
    CONSTRAINT UNQ_programs_program_name UNIQUE (program_name)
);

-- Tipos de servicio
CREATE TABLE service_types (
    id_service_type SERIAL,
    service_type_name VARCHAR(20) NOT NULL,
    CONSTRAINT PK_service_types PRIMARY KEY (id_service_type),
    CONSTRAINT UNQ_service_types_name UNIQUE (service_type_name)
);

-- ======================================================
-- TABLAS DEPENDIENTES (Tienen FK a tablas atómicas)
-- ======================================================

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
    id_guardian INTEGER,
    CONSTRAINT PK_persons PRIMARY KEY (id_person),
    CONSTRAINT UNQ_persons_identification UNIQUE (identification),
    CONSTRAINT UNQ_persons_email UNIQUE (email),
    CONSTRAINT FK_persons_document_types FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type) ON DELETE RESTRICT,
    CONSTRAINT FK_persons_guardian FOREIGN KEY (id_guardian)
        REFERENCES persons(id_person) ON DELETE SET NULL
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
    CONSTRAINT PK_users PRIMARY KEY (id_user),
    CONSTRAINT UNQ_users_identification UNIQUE (identification),
    CONSTRAINT UNQ_users_email UNIQUE (email),
    CONSTRAINT FK_users_roles FOREIGN KEY (id_role)
        REFERENCES roles(id_role) ON DELETE RESTRICT,
    CONSTRAINT FK_users_document_types FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type) ON DELETE RESTRICT
);

-- Proveedores
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
    id_document_type INT,
    CONSTRAINT PK_suppliers PRIMARY KEY (id_supplier),
    CONSTRAINT UNQ_suppliers_tax_id UNIQUE (tax_id),
    CONSTRAINT UNQ_suppliers_identification_number UNIQUE (identification_number),
    CONSTRAINT FK_suppliers_document_types FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type) ON DELETE RESTRICT,
    CONSTRAINT CHK_suppliers_name CHECK (
        (entity_type = 'juridica' AND company_name IS NOT NULL AND first_name IS NULL) OR
        (entity_type = 'natural' AND first_name IS NOT NULL AND company_name IS NULL)
    ),
    CONSTRAINT CHK_suppliers_id CHECK (
        (entity_type = 'juridica' AND tax_id IS NOT NULL AND identification_number IS NULL) OR
        (entity_type = 'natural' AND identification_number IS NOT NULL AND tax_id IS NULL)
    )
);

-- Compras
CREATE TABLE purchases (
    id_purchase SERIAL,
    invoice_number VARCHAR(50) NOT NULL,
    purchase_date DATE NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    id_supplier INTEGER NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_purchases PRIMARY KEY (id_purchase),
    CONSTRAINT UNQ_purchases_invoice_number UNIQUE (invoice_number),
    CONSTRAINT FK_purchases_suppliers FOREIGN KEY (id_supplier)
        REFERENCES suppliers(id_supplier) ON DELETE RESTRICT
);

-- Detalles de compra
CREATE TABLE purchase_details (
    id_purchase_detail SERIAL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    id_purchase INTEGER NOT NULL,
    id_sports_material INTEGER NOT NULL,
    CONSTRAINT PK_purchase_details PRIMARY KEY (id_purchase_detail),
    CONSTRAINT UNQ_purchase_details UNIQUE (id_purchase, id_sports_material),
    CONSTRAINT FK_purchase_details_purchases FOREIGN KEY (id_purchase)
        REFERENCES purchases(id_purchase) ON DELETE CASCADE,
    CONSTRAINT FK_purchase_details_sports_material FOREIGN KEY (id_sports_material)
        REFERENCES sports_material(id_sports_material) ON DELETE CASCADE
);

-- Empleados
CREATE TABLE employees (
    id_employee SERIAL,
    id_user INTEGER NOT NULL,
    id_employee_type INTEGER NOT NULL,
    age INT,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    status_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_employees PRIMARY KEY (id_employee),
    CONSTRAINT UNQ_employees_user_id UNIQUE (id_user),
    CONSTRAINT FK_employees_users FOREIGN KEY (id_user)
        REFERENCES users(id_user) ON DELETE RESTRICT,
    CONSTRAINT FK_employees_employee_types FOREIGN KEY (id_employee_type)
        REFERENCES employee_types(id_employee_type) ON DELETE RESTRICT
);

-- Horarios de empleados
CREATE TABLE employee_schedules (
    id_employee_schedule SERIAL,
    id_employee INTEGER NOT NULL,
    schedule_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description VARCHAR(255),
    status schedule_status NOT NULL,
    cancellation_reason VARCHAR(255),
    CONSTRAINT PK_employee_schedules PRIMARY KEY (id_employee_schedule),
    CONSTRAINT FK_employee_schedules_employees FOREIGN KEY (id_employee)
        REFERENCES employees(id_employee) ON DELETE CASCADE
);

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
    CONSTRAINT PK_donor_sponsors PRIMARY KEY (id_donor_sponsor),
    CONSTRAINT UNQ_donor_sponsors_tax_id UNIQUE (tax_id),
    CONSTRAINT FK_donor_sponsors_document_types FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type) ON DELETE RESTRICT
);

-- Donaciones
CREATE TABLE donations (
    id_donation SERIAL,
    id_donor_sponsor INT NOT NULL,
    quantity INT NOT NULL,
    description TEXT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    donation_type VARCHAR(50) NOT NULL,
    donation_date DATE NOT NULL,
    registration_date DATE NOT NULL,
    CONSTRAINT PK_donations PRIMARY KEY (id_donation),
    CONSTRAINT FK_donations_donor_sponsors FOREIGN KEY (id_donor_sponsor)
        REFERENCES donor_sponsors(id_donor_sponsor) ON DELETE RESTRICT
);

-- Detalles de donaciones
CREATE TABLE donation_details (
    id_donation_detail SERIAL,
    id_donation INT NOT NULL,
    id_sports_material INT NOT NULL,
    description VARCHAR(50) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    status BOOLEAN NOT NULL,
    observation VARCHAR(50),
    CONSTRAINT PK_donation_details PRIMARY KEY (id_donation_detail),
    CONSTRAINT FK_donation_details_donations FOREIGN KEY (id_donation)
        REFERENCES donations(id_donation) ON DELETE CASCADE,
    CONSTRAINT FK_donation_details_sports_material FOREIGN KEY (id_sports_material)
        REFERENCES sports_material(id_sports_material) ON DELETE RESTRICT
);

-- Deportistas
CREATE TABLE sportsmen (
    id_sportsman SERIAL,
    id_person INTEGER NOT NULL,
    id_sports_category INTEGER NOT NULL,
    age INT,
    CONSTRAINT PK_sportsmen PRIMARY KEY (id_sportsman),
    CONSTRAINT UNQ_sportsmen_id_person UNIQUE (id_person),
    CONSTRAINT FK_sportsmen_persons FOREIGN KEY (id_person)
        REFERENCES persons(id_person) ON DELETE RESTRICT,
    CONSTRAINT FK_sportsmen_sports_categories FOREIGN KEY (id_sports_category)
        REFERENCES sports_categories(id_sports_category) ON DELETE RESTRICT
);

-- Citas
CREATE TABLE appointments (
    id_appointment SERIAL,
    appointment_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    concept TEXT,
    id_sportsman INTEGER NOT NULL,
    id_employee INTEGER NOT NULL,
    id_program INTEGER NOT NULL,
    CONSTRAINT PK_appointments PRIMARY KEY (id_appointment),
    CONSTRAINT FK_appointments_sportsmen FOREIGN KEY (id_sportsman)
        REFERENCES sportsmen(id_sportsman) ON DELETE RESTRICT,
    CONSTRAINT FK_appointments_employees FOREIGN KEY (id_employee)
        REFERENCES employees(id_employee) ON DELETE RESTRICT,
    CONSTRAINT FK_appointments_programs FOREIGN KEY (id_program)
        REFERENCES programs(id_program) ON DELETE RESTRICT,
    CONSTRAINT CHK_appointments_status CHECK (status IN ('Programada', 'Cancelada', 'Ejecutada'))
);

-- Servicios
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
    CONSTRAINT FK_services_service_types FOREIGN KEY (id_service_type)
        REFERENCES service_types(id_service_type) ON DELETE RESTRICT
);

-- Personas temporales
CREATE TABLE temp_persons (
    id_temp_person SERIAL,
    person_type VARCHAR(30),
    name VARCHAR(100),
    id_document_type INT,
    identification VARCHAR(15),
    age INT,
    phone_number VARCHAR(20),
    birth_date DATE,
    id_sports_category INT,
    CONSTRAINT PK_temp_persons PRIMARY KEY (id_temp_person),
    CONSTRAINT FK_temp_persons_document_types FOREIGN KEY (id_document_type)
        REFERENCES document_types(id_document_type),
    CONSTRAINT FK_temp_persons_sports_categories FOREIGN KEY (id_sports_category)
        REFERENCES sports_categories(id_sports_category)
);

-- Equipos
CREATE TABLE teams (
    id_team SERIAL,
    team_name VARCHAR(100),
    id_sports_category INT,
    CONSTRAINT PK_teams PRIMARY KEY (id_team),
    CONSTRAINT FK_teams_sports_categories FOREIGN KEY (id_sports_category)
        REFERENCES sports_categories(id_sports_category)
);

-- ======================================================
-- TABLAS PUENTE (Relaciones N:M)
-- ======================================================

-- Roles - Permisos - Módulos
CREATE TABLE role_permissions (
    id_role_permission SERIAL,
    id_role INTEGER NOT NULL,
    id_permission INTEGER NOT NULL,
    id_module INTEGER NOT NULL,
    CONSTRAINT PK_role_permissions PRIMARY KEY (id_role_permission),
    CONSTRAINT UNQ_role_permissions_role_module_permission UNIQUE (id_role, id_module, id_permission),
    CONSTRAINT FK_role_permissions_roles FOREIGN KEY (id_role)
        REFERENCES roles(id_role) ON DELETE CASCADE,
    CONSTRAINT FK_role_permissions_permissions FOREIGN KEY (id_permission)
        REFERENCES permissions(id_permission) ON DELETE CASCADE,
    CONSTRAINT FK_role_permissions_modules FOREIGN KEY (id_module)
        REFERENCES modules(id_module) ON DELETE CASCADE
);

-- Inscripciones a servicios
CREATE TABLE service_registrations (
    id_service_registration SERIAL,
    id_person INT,
    id_temp_person INT,
    id_service INT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registration_status VARCHAR(50),
    CONSTRAINT PK_service_registrations PRIMARY KEY (id_service_registration),
    CONSTRAINT UNQ_service_registrations_id_person UNIQUE (id_person),
    CONSTRAINT UNQ_service_registrations_id_service UNIQUE (id_service),
    CONSTRAINT FK_service_registrations_persons FOREIGN KEY (id_person)
        REFERENCES persons(id_person),
    CONSTRAINT FK_service_registrations_temp_persons FOREIGN KEY (id_temp_person)
        REFERENCES temp_persons(id_temp_person),
    CONSTRAINT FK_service_registrations_services FOREIGN KEY (id_service)
        REFERENCES services(id_service)
);

-- Patrocinadores/Donantes con servicios
CREATE TABLE sponsors_services (
    id_sponsor_service SERIAL,
    id_service INT,
    id_donor_sponsor INT,
    sponsorship_description VARCHAR,
    CONSTRAINT PK_sponsors_services PRIMARY KEY (id_sponsor_service),
    CONSTRAINT FK_sponsors_services_services FOREIGN KEY (id_service)
        REFERENCES services(id_service),
    CONSTRAINT FK_sponsors_services_donor_sponsors FOREIGN KEY (id_donor_sponsor)
        REFERENCES donor_sponsors(id_donor_sponsor)
);

-- Miembros de equipo
CREATE TABLE team_members (
    id_team_member SERIAL,
    id_team INT,
    id_person INT,
    id_temp_person INT,
    role_in_team VARCHAR(50),
    CONSTRAINT PK_team_members PRIMARY KEY (id_team_member),
    CONSTRAINT FK_team_members_teams FOREIGN KEY (id_team)
        REFERENCES teams(id_team),
    CONSTRAINT FK_team_members_persons FOREIGN KEY (id_person)
        REFERENCES persons(id_person),
    CONSTRAINT FK_team_members_temp_persons FOREIGN KEY (id_temp_person)
        REFERENCES temp_persons(id_temp_person)
);

-- Inscripción de equipos
CREATE TABLE team_registrations (
    id_team_registration SERIAL,
    id_team INT,
    id_service INT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registration_status VARCHAR(50),
    CONSTRAINT PK_team_registrations PRIMARY KEY (id_team_registration),
    CONSTRAINT FK_team_registrations_teams FOREIGN KEY (id_team)
        REFERENCES teams(id_team),
    CONSTRAINT FK_team_registrations_services FOREIGN KEY (id_service)
        REFERENCES services(id_service)
);
