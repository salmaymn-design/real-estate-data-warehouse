

WITH dim_date AS (
    SELECT
        listing_date,
        ROW_NUMBER() OVER (ORDER BY listing_date) AS date_key
    FROM REAL_ESTATE_DB.SILVER.listings_clean
    WHERE listing_date IS NOT NULL
),

dim_energy AS (
    SELECT *
    FROM REAL_ESTATE_DB.GOLD.dim_energy
),

dim_location AS (
    SELECT *
    FROM REAL_ESTATE_DB.GOLD.dim_location
),

dim_property AS (
    SELECT *
    FROM REAL_ESTATE_DB.GOLD.dim_property
)

SELECT

    l.listing_id,

    d.date_key,
    e.energy_key,
    loc.location_key,
    p.property_key,

    l.price,
    l.surface_m2,
    l.num_rooms,
    l.num_bathrooms,
    l.floor,
    l.year_built

FROM REAL_ESTATE_DB.SILVER.listings_clean l

LEFT JOIN dim_date d
    ON l.listing_date = d.listing_date

LEFT JOIN dim_energy e
    ON l.energy_rating = e.energy_rating

LEFT JOIN dim_location loc
    ON l.country = loc.country
   AND l.city = loc.city
   AND l.neighborhood = loc.neighborhood

LEFT JOIN dim_property p
    ON l.property_type = p.property_type
   AND l.property_condition = p.property_condition
   AND l.heating_type = p.heating_type
   AND l.parking = p.parking