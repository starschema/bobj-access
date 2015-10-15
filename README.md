# bobj-access

Module for retrieving tables from published Business Objects reports 


# Installing

The package is on npm so you can get the latest version with:

```npm install bobj-access```

# Usage

``` javascript
var sap = require('bobj-access');
var wsdlUrl = '<path to the business objects published web service wsdl>'
var credentials = { username: 'sapuser', password: 'sappassword' };

sap.getTableList(wsdl, function(err, tables) {
    for (var i = 0; i < tables.length; i++) {
        var tableName = tables[i];
        sap.getFields(wsdl, credentials, tableName, function(err, fields) {
            console.log(err);
            console.log(fields);
            sap.getTableData(wsdl, credentials, tableName, function(err, data) {
                console.log(err);
                console.log(data);
            });
        });
    }
});
```

# Methods

## getTableList(wsdl, callback)
  * ```wsdl```: the URL of the Business Objects WSDL of a published web service
  * ```callback(err, tables)```
    * ```err```: null if everything was ok
    * ```tables```: An array of the tables in the provided report

## getFields(wsdl, credentials, tableName, callback)

  * ```wsdl```: the URL of the Business Objects WSDL of a published web service
  * ```credentials```: username and password for a user who can access the published service
  * ```tableName```: the name of the table the fields of which we are selecting
  * ```callback(err, fields)```
    * ```err```: null if everything was ok
    * ```fields```: An array of fields in the following format

      ``` javacript
      { 
        name: 'fieldName', 
        type: 'STRING'
      }
      ```
      
## getTableData(wsdl, credentials, tableName, options, callback)
  * ```wsdl```: the URL of the Business Objects WSDL of a published web service
  * ```credentials```: username and password for a user who can access the published service
  * ```tableName```: the name of the table the data of which we are selecting
  * ```options```: currently only the Limit can be set here but later the filters will be appliable as well
  * ```callback(err, rows)```
    * ```err```: null if everything was ok
    * ```rows```: A list objects with the following format

      ``` javacript
      { 
        fieldName: 'fieldValue'
      }
      ```
  
