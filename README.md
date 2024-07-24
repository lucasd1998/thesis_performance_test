<h1>Thesis - Performance comparition between Azure Cosmos DB and Azure SQL Database</h1>
Here you can find the source code for the master's thesis entitled "Performance comparison between Azure Cosmos DB (NoSQL API) and Azure SQL Database using Python libraries".

In this study, the performance of Azure Cosmos DB, a non-relational database, is compared with that of Azure SQL Database, a relational database, using CRUD operations. The response times of the databases for the specific use cases of the CRUD operations INSERT, SELECT, UPDATE and DELETE are measured and analyzed in order to draw conclusions about the performance of the two database types.

The folder "digital_appendix_thesis" contains all the appendices to the written Master's thesis and is used for illustration and better understanding. 
The ZIP-compressed folder "Project" represents the project with which the performance comparison was carried out. 

<h2>Instructions for carrying out the "Project" experiment</h2>

<br>The code within the experiment is intended for reproducibility.<br>

<table>
  <tr>
    <td><b>Prerequisites</b></td>
    <td>
      An Azure Cosmos DB and Azure SQL Database must be available in accordance with the configuration described in the thesis. The SQL files in "digital_appendix_thesis\thesis_prepare_azure_sql_database" 
      can be used to create the tables and stored procedures.</td>
  </tr>
</table>

<p>
<ol>
        <li>
            <b>Creating reference datasets and the database insertion sequence</b>
            <ol>
                <li>First, execute the file "01_Dataset_Generator/reference_dataset_generator.ipyn". This will create reference datasets for both Azure SQL Database and Azure Cosmos DB.</li>
                <li>Then, execute the file "01_Dataset_Generator/inserting_sequence_generator.ipyn". This will create a csv file named "sequence_of_inserting_data.csv", which determines the insertion sequence of the data records in the respective database.</li>
                <li>Copy the reference datasets from "01_Dataset_Generator\Reference_Datasets_Azure_Cosmos_DB" to "03_Experiments_Azure_Cosmos_DB\Reference_Datasets".</li>
                <li>Copy the reference datasets from "01_Dataset_Generator\Reference_Datasets_SQL_Database" to "03_Experiments_Azure_SQL_Database\Reference_Datasets".</li>
                <li>Copy the sequence file from "01_Dataset_Generator\sequence_of_inserting_data.csv" to "03_Experiments_Azure_Cosmos_DB".</li>
                <li>Copy the sequence file from "01_Dataset_Generator\sequence_of_inserting_data.csv" to "03_Experiments_Azure_SQL_Database".</li>
            </ol>
        </li>
  <br>
        <li> 
            <b>Replacing connection details in the configuration files for Azure Cosmos DB and Azure SQL Database</b>
            <ol>
                <li>Replace the connection details in Azure Cosmos DB in the file "03_Experiments_Azure_Cosmos_DB\config.json" according to the used Azure Cosmos DB.</li>
                <li>Replace the connection details in Azure SQL Database in the file "03_Experiments_Azure_SQL_Database\config.json" according to the used Azure SQL Database.</li>
            </ol>
        </li>
  <br>
        <li><b>Start the internet speed test by executing "02_Internet_Speedtest\internet_speedtest.py".</b></li>
  <br>
        <li><b>Simultaneously start the Jupyter Notebook files "03_Experiments_Azure_Cosmos_DB\azure_cosmos_db_experiment.ipyn" and "03_Experiments_Azure_SQL_Database\azure_sql_database_experiment.ipyn".</b></li>
  <br>
        <li>
            <b>After successful completion of the experiments, copy the created CSV result files</b>
            <ol>
                <li>Copy the result files from "02_Internet_Speedtest\internet_speedtest_results.csv" to "04_Creation_Of_Charts\Experiment_Results_Internet_Speedtest".</li>
                <li>Copy the result files from "03_Experiments_Azure_Cosmos_DB\Experiment_Results" to "04_Creation_Of_Charts\Experiment_Results_Azure_Cosmos_DB".</li>
                <li>Copy the result files from "03_Experiments_Azure_SQL_Database\Experiment_Results" to "04_Creation_Of_Charts\Experiment_Results_Azure_SQL_Database".</li>
            </ol>
        </li>
        <li><b>Finally, execute the file "04_Creation_Of_Charts\chart_creator.ipyn".</b></li>
    </ol>
  </p>
