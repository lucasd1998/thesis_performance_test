CREATE PROCEDURE SP_DeleteAllInspectionData
AS
BEGIN
    -- Set NOCOUNT ON to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Begin a transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Delete from InspectionResults
        DELETE FROM InspectionResults;

        -- 2. Delete from InspectionsToSetpoints
        DELETE FROM InspectionsToSetpoints;

        -- 3. Delete from Inspections
        DELETE FROM Inspections;

        -- 4. Delete from Setpoints
        DELETE FROM Setpoints;

        -- 5. Delete from InspectionStep
        DELETE FROM InspectionStep;

        -- 6. Delete from InspectionOperations
        DELETE FROM InspectionOperations;

        -- Commit the transaction if all deletes were successful
        COMMIT TRANSACTION;

        PRINT 'Deletion Successful!';
    END TRY
    BEGIN CATCH
        -- Rollback the transaction if any delete fails
        ROLLBACK TRANSACTION;

        -- Get the error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Return the error details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;