

WITH source AS (

    SELECT *
    FROM REAL_ESTATE_DB.BRONZE.RAW_LISTINGS

),
cleaned AS (

    SELECT

        "listing_id" AS listing_id,

        NULLIF(INITCAP(TRIM("property_type")), '') AS property_type,
        NULLIF(INITCAP(TRIM("country")), '') AS country,
        NULLIF(INITCAP(TRIM("city")), '') AS city,
        NULLIF(INITCAP(TRIM("neighborhood")), '') AS neighborhood,

        TRY_TO_NUMBER(NULLIF(TRIM("surface_m2"), '')) AS surface_m2,
        TRY_TO_NUMBER(NULLIF(TRIM("num_rooms"), '')) AS num_rooms,
        TRY_TO_NUMBER(NULLIF(TRIM("num_bathrooms"), '')) AS num_bathrooms,
        TRY_TO_NUMBER(NULLIF(TRIM("floor"), '')) AS floor,
        TRY_TO_NUMBER(NULLIF(TRIM("year_built"), '')) AS year_built,

        TRY_TO_NUMBER(
            REGEXP_REPLACE("price", '[^0-9.]', '')
        ) AS price,

        COALESCE(
            TRY_TO_DATE("listing_date",'YYYY-MM-DD'),
            TRY_TO_DATE("listing_date",'DD/MM/YYYY'),
            TRY_TO_DATE("listing_date",'MM/DD/YYYY')
        ) AS listing_date,

        NULLIF(INITCAP(TRIM("condition")), '') AS property_condition,
        NULLIF(INITCAP(TRIM("heating_type")), '') AS heating_type,

        CASE
            WHEN LOWER(TRIM("parking")) IN ('yes','y','true','1') THEN 'Yes'
            WHEN LOWER(TRIM("parking")) IN ('no','n','false','0') THEN 'No'
            ELSE NULL
        END AS parking,

        NULLIF(UPPER(TRIM("energy_rating")), '') AS energy_rating,

        ROW_NUMBER() OVER (
            PARTITION BY "listing_id"
            ORDER BY
                COALESCE(
                    TRY_TO_DATE("listing_date",'YYYY-MM-DD'),
                    TRY_TO_DATE("listing_date",'DD/MM/YYYY'),
                    TRY_TO_DATE("listing_date",'MM/DD/YYYY')
                ) DESC
        ) AS rn

    FROM source

),

stats AS (

    SELECT

        MEDIAN(surface_m2) AS median_surface_m2,
        MEDIAN(num_rooms) AS median_num_rooms,
        MEDIAN(num_bathrooms) AS median_num_bathrooms,
        MEDIAN(floor) AS median_floor,
        MEDIAN(year_built) AS median_year_built,

        MODE(country) AS mode_country,
        MODE(neighborhood) AS mode_neighborhood,
        MODE(property_condition) AS mode_property_condition,
        MODE(heating_type) AS mode_heating_type,
        MODE(parking) AS mode_parking,
        MODE(energy_rating) AS mode_energy_rating,
        MODE(listing_date) AS mode_listing_date

    FROM cleaned

    WHERE rn = 1

)

SELECT

    c.listing_id,
    c.property_type,

    COALESCE(c.country, s.mode_country) AS country,
    c.city,
    COALESCE(c.neighborhood, s.mode_neighborhood) AS neighborhood,

    COALESCE(c.surface_m2, s.median_surface_m2) AS surface_m2,
    COALESCE(c.num_rooms, s.median_num_rooms) AS num_rooms,
    COALESCE(c.num_bathrooms, s.median_num_bathrooms) AS num_bathrooms,
    COALESCE(c.floor, s.median_floor) AS floor,
    COALESCE(c.year_built, s.median_year_built) AS year_built,

    c.price,

    COALESCE(c.listing_date, s.mode_listing_date) AS listing_date,

    COALESCE(c.property_condition, s.mode_property_condition) AS property_condition,
    COALESCE(c.heating_type, s.mode_heating_type) AS heating_type,
    COALESCE(c.parking, s.mode_parking) AS parking,
    COALESCE(c.energy_rating, s.mode_energy_rating) AS energy_rating

FROM cleaned c
CROSS JOIN stats s

WHERE c.rn = 1
  AND c.price BETWEEN 10000 AND 100000000
  AND COALESCE(c.surface_m2, s.median_surface_m2) BETWEEN 10 AND 5000