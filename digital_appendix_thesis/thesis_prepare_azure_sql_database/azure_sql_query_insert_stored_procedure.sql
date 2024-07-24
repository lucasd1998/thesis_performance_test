CREATE PROCEDURE SP_InsertInspectionOperation (
    @JsonData NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION; -- Start transaction

        -- Create temporary tables
        CREATE TABLE #TempInspectionOperation (
            OrderNumber VARCHAR(10),
            ArticleName VARCHAR(20),
            MachineName VARCHAR(50),
            SerialNumber VARCHAR(10)
        );

        CREATE TABLE #TempInspection (
            InspectionStepNumber VARCHAR(3),
            InspectionStepID INT,
            InspectionName VARCHAR(100),
            LowerBorderValue VARCHAR(30),
            TargetValue VARCHAR(30),
            UpperBorderValue VARCHAR(30),
            Unit VARCHAR(30),
            InspectionIndex INT
        );

        CREATE TABLE #TempInspectionResult (
            InspectionIndex INT,
            MeasuredValue VARCHAR(10),
            Passed VARCHAR(5)
        );

        CREATE TABLE #TempInspectionSetpoint (
            InspectionIndex INT,
            SetpointName VARCHAR(100),
            SetpointValue VARCHAR(20)
        );

        -- Insert data from the JSON into the temporary tables
        INSERT INTO #TempInspectionOperation (OrderNumber, ArticleName, MachineName, SerialNumber)
        SELECT 
            OrderNumber,
            ArticleName,
            MachineName,
            SerialNumber
        FROM OPENJSON(@JsonData)
        WITH (
            OrderNumber VARCHAR(10),
            ArticleName VARCHAR(20),
            MachineName VARCHAR(50),
            SerialNumber VARCHAR(10)
        );

        -- Extract the index of each inspection
        INSERT INTO #TempInspection (InspectionStepNumber, InspectionStepID, InspectionName, LowerBorderValue, TargetValue, UpperBorderValue, Unit, InspectionIndex)
        SELECT 
            InspectionStep,
            NULL, -- InspectionStepID is set later
            InspectionName,
            InspectionLowerBorderValue,
            InspectionTargetValue,
            InspectionUpperBorderValue,
            InspectionUnit,
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS InspectionIndex
        FROM OPENJSON(@JsonData, '$.InspectionsAndResults')
        WITH (
            InspectionStep VARCHAR(3),
            InspectionName VARCHAR(100),
            InspectionLowerBorderValue VARCHAR(30),
            InspectionTargetValue VARCHAR(30),
            InspectionUpperBorderValue VARCHAR(30),
            InspectionUnit VARCHAR(30)
        );

        INSERT INTO #TempInspectionResult (InspectionIndex, MeasuredValue, Passed)
        SELECT 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS InspectionIndex,
            InspectionResultMeasuredValue,
            InspectionResultPassed
        FROM OPENJSON(@JsonData, '$.InspectionsAndResults')
        WITH (
            InspectionResultMeasuredValue VARCHAR(10),
            InspectionResultPassed VARCHAR(5)
        );

        -- Extract setpoints and save the index of the inspection
        DECLARE @InspectionIndex INT;
        DECLARE @SetpointName VARCHAR(100);
        DECLARE @SetpointValue VARCHAR(20);

        DECLARE setpoint_cursor CURSOR FOR
        SELECT InspectionIndex
        FROM #TempInspection;

        OPEN setpoint_cursor;
        FETCH NEXT FROM setpoint_cursor INTO @InspectionIndex;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO #TempInspectionSetpoint (InspectionIndex, SetpointName, SetpointValue)
            SELECT @InspectionIndex, [key], value
            FROM OPENJSON(@JsonData, '$.InspectionsAndResults[' + CAST(@InspectionIndex AS NVARCHAR(10)) + '].InspectionSetpoints');

            FETCH NEXT FROM setpoint_cursor INTO @InspectionIndex;
        END;

        CLOSE setpoint_cursor;
        DEALLOCATE setpoint_cursor;

        -- Insert InspectionOperation
        DECLARE @InspectionOperationID INT;
        INSERT INTO InspectionOperations (OrderNumber, ArticleName, MachineName, SerialNumber, InspectionDateTime, UpdateDateTime)
        SELECT OrderNumber, ArticleName, MachineName, SerialNumber, GETDATE(), GETDATE()
        FROM #TempInspectionOperation;

        SET @InspectionOperationID = SCOPE_IDENTITY(); -- Save InspectionOperation-ID for future use

        -- Inserting inspections
        DECLARE @InspectionID INT;
        DECLARE @InspectionStepNumber VARCHAR(3);
        DECLARE @InspectionStepID INT;
        DECLARE @InspectionName VARCHAR(100);
        DECLARE @LowerBorderValue VARCHAR(30);
        DECLARE @TargetValue VARCHAR(30);
        DECLARE @UpperBorderValue VARCHAR(30);
        DECLARE @Unit VARCHAR(30);

        DECLARE inspection_cursor CURSOR FOR
        SELECT InspectionStepNumber, InspectionStepID, InspectionName, LowerBorderValue, TargetValue, UpperBorderValue, Unit, InspectionIndex
        FROM #TempInspection;

        OPEN inspection_cursor;
        FETCH NEXT FROM inspection_cursor INTO @InspectionStepNumber, @InspectionStepID, @InspectionName, @LowerBorderValue, @TargetValue, @UpperBorderValue, @Unit, @InspectionIndex;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Insert or select existing InspectionStepID
            IF NOT EXISTS (
                SELECT 1 
                FROM InspectionStep 
                WHERE InspectionName = @InspectionName 
                  AND LowerBorderValue = @LowerBorderValue 
                  AND TargetValue = @TargetValue 
                  AND UpperBorderValue = @UpperBorderValue 
                  AND Unit = @Unit
            )
            BEGIN
                INSERT INTO InspectionStep (InspectionName, LowerBorderValue, TargetValue, UpperBorderValue, Unit)
                VALUES (@InspectionName, @LowerBorderValue, @TargetValue, @UpperBorderValue, @Unit);

                SET @InspectionStepID = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SELECT @InspectionStepID = InspectionStepID 
                FROM InspectionStep 
                WHERE InspectionName = @InspectionName 
                  AND LowerBorderValue = @LowerBorderValue 
                  AND TargetValue = @TargetValue 
                  AND UpperBorderValue = @UpperBorderValue 
                  AND Unit = @Unit;
            END;

            INSERT INTO Inspections (InspectionOperationID, InspectionStepNumber, InspectionStepID)
            VALUES (@InspectionOperationID, @InspectionStepNumber, @InspectionStepID);

            SET @InspectionID = SCOPE_IDENTITY(); -- Save inspection ID for future use

            -- Inserting InspectionResults
            INSERT INTO InspectionResults (InspectionID, MeasuredValue, Passed)
            SELECT @InspectionID, MeasuredValue, Passed
            FROM #TempInspectionResult
            WHERE InspectionIndex = @InspectionIndex;

            -- Inserting setpoints
            DECLARE @SetpointID INT;
            DECLARE setpoint_cursor2 CURSOR FOR
            SELECT SetpointName, SetpointValue
            FROM #TempInspectionSetpoint
            WHERE InspectionIndex = @InspectionIndex;

            OPEN setpoint_cursor2;
            FETCH NEXT FROM setpoint_cursor2 INTO @SetpointName, @SetpointValue;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Insert or select existing SetpointID
                IF NOT EXISTS (SELECT 1 FROM Setpoints WHERE SetpointName = @SetpointName AND SetpointValue = @SetpointValue)
                BEGIN
                    INSERT INTO Setpoints (SetpointName, SetpointValue)
                    VALUES (@SetpointName, @SetpointValue);

                    SET @SetpointID = SCOPE_IDENTITY();
                END
                ELSE
                BEGIN
                    SELECT @SetpointID = SetpointID FROM Setpoints WHERE SetpointName = @SetpointName AND SetpointValue = @SetpointValue;
                END;

                INSERT INTO InspectionsToSetpoints (InspectionID, SetpointID)
                VALUES (@InspectionID, @SetpointID);

                FETCH NEXT FROM setpoint_cursor2 INTO @SetpointName, @SetpointValue;
            END;

            CLOSE setpoint_cursor2;
            DEALLOCATE setpoint_cursor2;

            FETCH NEXT FROM inspection_cursor INTO @InspectionStepNumber, @InspectionStepID, @InspectionName, @LowerBorderValue, @TargetValue, @UpperBorderValue, @Unit, @InspectionIndex;
        END;
        CLOSE inspection_cursor;
        DEALLOCATE inspection_cursor;

        -- Complete transaction
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Undo transaction in the event of an error
        IF @@TRANCOUNT > 0
            ROLLBACK;

        -- Output or forward error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;

    -- Delete temporary tables
    IF OBJECT_ID('tempdb..#TempInspectionOperation') IS NOT NULL
        DROP TABLE #TempInspectionOperation;

    IF OBJECT_ID('tempdb..#TempInspection') IS NOT NULL
        DROP TABLE #TempInspection;

    IF OBJECT_ID('tempdb..#TempInspectionResult') IS NOT NULL
        DROP TABLE #TempInspectionResult;

    IF OBJECT_ID('tempdb..#TempInspectionSetpoint') IS NOT NULL
        DROP TABLE #TempInspectionSetpoint;
END;