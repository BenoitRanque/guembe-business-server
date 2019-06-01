BEGIN;

CREATE SCHEMA website;

CREATE TABLE website.image (
    image_id
    format_id
    name
    placeholder
);
CREATE TABLE website.image_format (
    format_id
    name TEXT UNIQUE
);
CREATE TABLE website.image_format_size (
    format_id
    name
    width
    height
);

CREATE TABLE website.page (
    page_id
    background_image_id
    title
    subtitle
);


CREATE SCHEMA localization;

CREATE TABLE locale (
    locale_id TEXT PRIMARY KEY;
    name TEXT NOT NULL;
);

-- create tables as before on relevant schema. Omit any localized information
CREATE TABLE webstore.product (
    product_id UUID PRIMARY KEY,
    name TEXT, -- this field not translated
    cost INT
);
-- create table on localization schema. Create just after relevant table.
-- include all translated fields here
CREATE TABLE localization.webstore_product (
    product_id UUID REFERENCES webstore.product (product_id)
        ON DELETE CASCADE,
    locale_id TEXT REFERENCES localization.locale (locale_id),
    PRIMARY KEY(product_id, locale_id),
    public_name -- this field translated
    description -- this field tranlated in multiple languages
);


CREATE TABLE localization.translation (
    translation_id TEXT
    locale_id REFERENCES localization.locale (locale_id),
    PRIMARY KEY(product_id, locale_id),
    public_name -- this field translated
);

CREATE TABLE product_localization


query ($locale: { locale_id: { _eq: 'en' } }) {
    product {
        name
        local (where: $locale) {
            public_name
            description
        }
    }
}

const response = {
    products: [
        {
            name: 'non localized name',
            localized: {
                public_name: 'Localized field',
                description: 'Localized field'
            }
        }
    ]
}


CREATE TABLE website.page_slide ();
CREATE TABLE website.page_panel ();
CREATE TABLE website.page_card ();
CREATE TABLE website.page ();

COMMIT;