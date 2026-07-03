
  
    

create or replace transient table REAL_ESTATE_DB.GOLD.dim_location
    
    
    
    as (

SELECT

    ROW_NUMBER() OVER (
        ORDER BY country, city, neighborhood
    ) AS location_key,

    country,
    city,
    neighborhood

FROM (

    SELECT DISTINCT

        country,
        city,
        neighborhood

    FROM REAL_ESTATE_DB.SILVER.listings_clean

)
    )
;


  