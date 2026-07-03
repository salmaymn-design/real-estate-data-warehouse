
  
    

create or replace transient table REAL_ESTATE_DB.GOLD.dim_energy
    
    
    
    as (

SELECT

    ROW_NUMBER() OVER (ORDER BY energy_rating) AS energy_key,
    energy_rating

FROM (

    SELECT DISTINCT energy_rating
    FROM REAL_ESTATE_DB.SILVER.listings_clean
    WHERE energy_rating IS NOT NULL

)
    )
;


  