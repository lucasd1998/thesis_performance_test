CREATE TABLE InspectionOperations (
    InspectionOperationID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber VARCHAR(10),
	ArticleName VARCHAR(100),
    MachineName VARCHAR(100),
	SerialNumber VARCHAR(10),
	InspectionDateTime DATETIME,
    UpdateDateTime DATETIME,
);

-- Creating indexes on SerialNumber and ArticleName
CREATE INDEX IDX_InspectionOperations_SerialNumber ON InspectionOperations(SerialNumber);
CREATE INDEX IDX_InspectionOperations_ArticleName ON InspectionOperations(ArticleName);

CREATE TABLE Inspections (
    InspectionID INT IDENTITY(1,1) PRIMARY KEY,
    InspectionOperationID INT,
    InspectionStepNumber VARCHAR(5),
    InspectionStepID INT,
    FOREIGN KEY (InspectionOperationID) REFERENCES InspectionOperations(InspectionOperationID) ON DELETE CASCADE
);


CREATE TABLE InspectionResults (
    InspectionResultID INT IDENTITY(1,1) PRIMARY KEY,
    InspectionID INT,
    MeasuredValue VARCHAR(100),
    Passed VARCHAR(10),
    FOREIGN KEY (InspectionID) REFERENCES Inspections(InspectionID) ON DELETE CASCADE
);


CREATE TABLE InspectionsToSetpoints (
    InspectionsToSetpointID INT IDENTITY(1,1) PRIMARY KEY,
    InspectionID INT,
    SetpointID INT,
    FOREIGN KEY (InspectionID) REFERENCES Inspections(InspectionID) ON DELETE CASCADE
);

CREATE TABLE Setpoints (
    SetpointID INT IDENTITY(1,1) PRIMARY KEY,
    SetpointName VARCHAR(100),
    SetpointValue VARCHAR(10)
);


ALTER TABLE InspectionsToSetpoints
ADD CONSTRAINT FK_InspectionsToSetpoints_SetpointID
FOREIGN KEY (SetpointID) REFERENCES Setpoints(SetpointID)
ON DELETE CASCADE;


CREATE TABLE InspectionStep (
    InspectionStepID INT IDENTITY(1,1) PRIMARY KEY,
    InspectionName VARCHAR(100),
    LowerBorderValue VARCHAR(30),
    TargetValue VARCHAR(30),
    UpperBorderValue VARCHAR(30),
    Unit VARCHAR(100)
);


ALTER TABLE Inspections
ADD CONSTRAINT FK_Inspections_InspectionStepID
FOREIGN KEY (InspectionStepID) REFERENCES InspectionStep(InspectionStepID)
ON DELETE CASCADE;