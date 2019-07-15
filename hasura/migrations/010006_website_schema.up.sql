BEGIN;
CREATE SCHEMA website;

CREATE TABLE website.size (
    size_id TEXT PRIMARY KEY
);
INSERT INTO website.size (size_id)
VALUES ('xl'), ('lg'), ('md'), ('sm'), ('xs');

CREATE TABLE website.format (
    format_id TEXT PRIMARY KEY,
    name TEXT
);


CREATE TABLE website.format_size (
    format_id TEXT REFERENCES website.format (format_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    size_id TEXT REFERENCES website.size (size_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
	PRIMARY KEY (format_id, size_id),
    width INTEGER NOT NULL CHECK (width >= 0),
    height INTEGER NOT NULL CHECK (height >= 0)
);

CREATE TABLE website.image (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    format_id TEXT NOT NULL REFERENCES website.format (format_id),
    name TEXT,
    placeholder TEXT,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_image_set_updated_at BEFORE UPDATE ON website.image
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.page (
    page_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    path TEXT UNIQUE, -- nullable because preliminary pages will not have path
    preliminary_path TEXT,
    CHECK ((path IS NOT NULL AND preliminary_path IS NULL) OR (path IS NULL AND preliminary_path IS NOT NULL)),
	name TEXT NOT NULL,
    image_id UUID REFERENCES website.image (image_id) ON DELETE RESTRICT,
    editable BOOLEAN NOT NULL DEFAULT true, -- can(not) be edited
    protected BOOLEAN NOT NULL DEFAULT false, -- can(not) be deleted
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_page_set_updated_at BEFORE UPDATE ON website.page
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.page_i18n (
    page_id UUID REFERENCES website.page (page_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY (page_id, locale_id),
	name TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_page_i18n_set_updated_at BEFORE UPDATE ON website.page_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.section (
    section_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	page_id UUID NOT NULL REFERENCES website.page (page_id)
        ON DELETE CASCADE,
    index INTEGER NOT NULL CHECK (index >= 0),
    UNIQUE(page_id, index) DEFERRABLE INITIALLY IMMEDIATE,
    fullwidth BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_section_set_updated_at BEFORE UPDATE ON website.section
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.element (
    element_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES website.section (section_id)
        ON DELETE CASCADE,
    index INTEGER NOT NULL CHECK (index >= 0),
    UNIQUE (section_id, index) DEFERRABLE INITIALLY IMMEDIATE,
    size_id TEXT NOT NULL REFERENCES website.size (size_id),
    internal_link TEXT REFERENCES website.page (path)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    external_link TEXT,
    -- listing link added after webstore schema created
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_element_set_updated_at BEFORE UPDATE ON website.element
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.element_i18n (
	element_id UUID REFERENCES website.element (element_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY (element_id, locale_id),
    image_id UUID REFERENCES website.image (image_id) ON DELETE RESTRICT,
    caption TEXT,
    title TEXT,
    subtitle TEXT,
	body TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_element_i18n_set_updated_at BEFORE UPDATE ON website.element_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;