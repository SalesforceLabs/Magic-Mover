/**
* @author Dayana Daniel
* @description Mock to pretends to make the callout
* the body is a JSON with 12 objects (11 valid and 1 invalid).
* We use this mock since is not possible to make unit tests using callouts, 
* because of that we simulate the response.
*/

global with sharing class NMTRetrieveMetadataMock implements HTTPCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody('{"size":102,"totalSize":102,"done":true,"queryLocator":null,"entityTypeName":"Layout",'
                    +'"records":[{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbiYAAQ"},'
                    +'"EntityDefinitionId":"Account","EntityDefinition":'
                    +'{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Account"},"DeveloperName":"Account"},'
                    +'"Name":"Account (Marketing) Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000000nP9BAAU"},"EntityDefinitionId":"01If4000000QaO9",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/01If4000000QaO9"},'
                    +'"DeveloperName":"AttachmentConversionStatus"},"Name":"AttachmentConversionStatus Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbjYAAQ"},"EntityDefinitionId":"Metric"'
                    +',"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Metric"},"DeveloperName":"Metric"},'
                    +'"Name":"Completion Metric Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbiUAAQ"},"EntityDefinitionId":"Contact",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Contact"},"DeveloperName":"Contact"},'
                    +'"Name":"Contact (Marketing) Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbjJAAQ"},"EntityDefinitionId":"Contract",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Contract"},"DeveloperName":"Contract"},'
                    +'"Name":"Contract Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbjUAAQ"},"EntityDefinitionId":"Goal",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Goal"},"DeveloperName":"Goal"},'
                    +'"Name":"Goal Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbjLAAQ"},"EntityDefinitionId":"Idea",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Idea"},"DeveloperName":"Idea"},'
                    +'"Name":"Idea Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbicAAA"},"EntityDefinitionId":"Lead",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Lead"},"DeveloperName":"Lead"},'
                    +'"Name":"Lead (Marketing) Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbidAAA"},"EntityDefinitionId":"Lead",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Lead"},"DeveloperName":"Lead"},'
                    +'"Name":"Lead (Sales) Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbieAAA"},"EntityDefinitionId":"Lead",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Lead"},"DeveloperName":"Lead"},'
                    +'"Name":"Lead (Support) Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbijAAA"},"EntityDefinitionId":"Macro",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Macro"},"DeveloperName":"Macro"},'
                    +'"Name":"Macro Layout"},'
                    +'{"attributes":{"type":"Layout","url":"/services/data/v40.0/tooling/sobjects/Layout/00hf4000001bbiQAAQ"},"EntityDefinitionId":"Opportunity",'
                    +'"EntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v40.0/tooling/sobjects/EntityDefinition/Opportunity"},"DeveloperName":"Opportunity"},'
                    +'"Name":"Opportunity (Marketing) Layout"}'
                    +']}');
                   
        res.setStatusCode(200);
        return res;
    }
}