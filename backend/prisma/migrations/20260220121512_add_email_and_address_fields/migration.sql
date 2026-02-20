-- AlterTable
ALTER TABLE "donor_profiles" ADD COLUMN     "city" TEXT,
ADD COLUMN     "latitude" DOUBLE PRECISION,
ADD COLUMN     "longitude" DOUBLE PRECISION,
ADD COLUMN     "quarter" TEXT,
ADD COLUMN     "street" TEXT,
ADD COLUMN     "town" TEXT;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "email" TEXT;
