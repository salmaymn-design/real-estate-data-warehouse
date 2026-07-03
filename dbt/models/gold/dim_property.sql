{{ config(
    materialized='table',
    schema='GOLD'
) }}

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

    FROM {{ ref('listings_clean') }}

)