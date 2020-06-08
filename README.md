# **ShopSystems UI Test Runner**

This project runs acceptance tests for Wirecard Shop Systems extensions. 

Supported Shop Systems
========

|  Shop system | Supported | This project used in CI |   
|---|---|:---:|  
| **Woocommerce** | &#9989; | &#9989; |


How to include project and run tests in continuous integration:
========
Clone to your workspace and use it in your workflow like in e.g
`https://github.com/wirecard/woocommerce-ee/blob/master/.github/workflows/run-acceptance-tests.yml` 


Configuring other
=====
It is possible to extend this project with specific shop system. Add new data with respective output file paths in
`configuration.json` file content:
`````
{
  "woocommerce": {
      "html": "wirecard-woocommerce-extension/vendor/wirecard/shopsystem-ui-testsuite/tests/_output/*.html",
      "xml": "wirecard-woocommerce-extension/vendor/wirecard/shopsystem-ui-testsuite/tests/_output/*.xml",
      "png": "wirecard-woocommerce-extension/vendor/wirecard/shopsystem-ui-testsuite/tests/_output/*.fail.png"
    }
}
`````

Also add a new folder for the respective shop system and it docker files with script for spinning the shop system.


Structure
=====


    .
    ├── .bin                                # generic scripts folder
    |    ├── run-ui-tests.sh                # run ui tests
    |    | 
    |    ├── send-notify.sh                 # send slack notification to respective channel 
    |    |
    |    |── setup-and-run-ui-tests.sh      # run all scripts
    |    |           
    |    ├── start-ngrok.sh                 # start ngrok tunnel  
    |    |  
    |    ├── upload-logs-and-notify.sh      # upload test results  
    ├── woocommerce-ee                      # woocommerce related files
    |    ├── .env                           # environemnt variables
    |    | 
    |    ├── compatible-shop-releases.txt   # compatible shop versions
    |    | 
    |    ├── docker-compose.yml       
    |    |
    |    ├── Dockerfile                     # woocommerce Dockerfile
    |    |
    |    |── Dockerfile_codeception         # codeception Dockerfile
    |    |
    |    |── setup-and-run-ui-tests.sh      # run all scripts
    |    |           
    |    ├── generate-release-package.sh    # generate release package zip file 
    |    |  
    |    ├── start-shopsystem.sh            # start shop system  
    ├── configuration.json                  # test results output paths
    ├── LICENSE
    └── README.md
