

SELECT

    ROW_NUMBER() OVER (
        ORDER BY property_type,
                 property_condition,
                 heating_type,
                 parking
    ) AS property_key,

    property_type,
    property_condition,
    heating_type,
    parking

FROM (

    SELECT DISTINCT

        property_type,
        property_condition,
        heating_type,
        parking

    FROM REAL_ESTATE_DB.SILVER.listings_clean

)