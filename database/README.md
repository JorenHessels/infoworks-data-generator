## Database Instructions

In order for the application to have the ability to access your database, it needs a `Standalone.icmm` file, along with the data folder with the GUID of your database.

For example:\
📦database \
┣ 📂8B45EFEB-FB27-4F8A-B293-E8F8DC8947A4 \
┣ 📜Standalone.icmm \
┗ 📜README.md

Open this database in InfoWorks ICM first to verify that all the data you want to use is there.

### Transportable Databases
If you are using a transportable database (`.icmt` file), you will have to convert it into a `.icmm` file first. A guide on this can be found [here](https://help.autodesk.com/view/IWICMS/2026/ENU/?guid=GUID-A583C712-4723-4D3E-B203-0A3084217450).

### Scenarios
The application assumes that the scenario where you want to simulations is based on the `'Base'` scenario and will create a new scenario called `'Generator'`. If you don't want it to be based on `'Base'` or if `'Generator'` is already a scenario. please change this at the top of `generator.rb`