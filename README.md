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

sap.getTables(wsdlUrl, credentials, function(err, tables) {
  if (!err) {
    console.log("Got definition of tables: ", tables);
  }
});

sap.getTableData(wsdlUrl, credentials, function(err, rows) {
  if (!err) {
    for (var i = 0; i < rows.length; i++) {
      console.log("Row in data: ", rows[i]);
    }
  }
});
```

# Methods

## getTables(wsdl, credentials, callback)

  * ```wsdl```: the URL of the Business Objects WSDL of a published web service
  * ```credentials```: username and password for a user who can access the published service
  * ```callback(err, tables)```
    * ```err```: null if everything was ok
    * ```tables```: A list of items in the following format. 

      ``` javacript
      { 
        Name: 'tablename', 
        Fields: [ {
          name: 'fieldName', 
          type: 'STRING'
        } ] 
      }
      ```
      
## getTableData(wsdl, credentials, callback)
  * ```wsdl```: the URL of the Business Objects WSDL of a published web service
  * ```credentials```: username and password for a user who can access the published service
  * ```callback(err, rows)```
    * ```err```: null if everything was ok
    * ```rows```: A list objects with the following format

      ``` javacript
      { 
        fieldName: 'fieldValue'
      }
      ```
  
