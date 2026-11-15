
BEGIN;

UPDATE "BranchProducts"
SET "is_in_stock" = true
WHERE "product_id" IN (
    SELECT "id"
    FROM "Products"
    WHERE "is_active" = true
);

COMMIT;
