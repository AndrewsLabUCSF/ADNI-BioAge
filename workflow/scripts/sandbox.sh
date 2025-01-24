scp -r ADNIMERGE_25Sep2023.csv sjfandrews@dt1.wynton.ucsf.edu:/wynton/group/andrews/data/adni/data/phenotypes
scp sjfandrews@dt1.wynton.ucsf.edu:/wynton/group/andrews/users/sjfandrews/DNAm/intermediate/adni_DNAm_calc.csv.gz ~/Downloads
scp sjfandrews@dt1.wynton.ucsf.edu:/wynton/group/andrews/users/sjfandrews/DNAm/intermediate/adni_betaSet.tsv.gz ~/Downloads
scp sjfandrews@dt1.wynton.ucsf.edu:/wynton/group/andrews/users/sjfandrews/DNAm/intermediate/master_sheet_cell-types_85bsc.csv ~/Downloads
mamba env create -f workflow/envs/R.yaml

scp sjfandrews@dt1.wynton.ucsf.edu:/yokoyama/seqdata/afrprs/PRScsx/work/adgc/adgc_META_pst_eff_a1_b0.5_phiauto_chrAll_noAPOE.txt ~/Downloads


scp one_file.tsv alice@dt1.wynton.ucsf.edu:~/

if isinstance(imputed_dataset.metadata, pd.DataFrame):
    # Calculate missing data count per sample (column)
    missing_data_counts = imputed_dataset.metadata.isnull().sum()
    
    # Filter samples (columns) with more than 0 missing values
    samples_with_missing_data = missing_data_counts[missing_data_counts > 0]
    
    # Print the samples with more than 0 missing values
    print("Samples with missing data:")
    print(samples_with_missing_data)
    

if isinstance(data.dnam, pd.DataFrame):
    print(data.metadata.head())

import pandas as pd

# Replace 'path/to/your/file.csv' with the path to the CSV file you want to import
csv_file_path = '/Users/sheaandrews/Downloads/adni_DNAm_calc.csv'
metadata_path = "~/Downloads/adni_biolearn_metadata.csv"


# Read the CSV file into a DataFrame
df = pd.read_csv(csv_file_path)
df.set_index('ProbeID', inplace=True)
df.index.name = 'id'


# Specify the path to your compressed TSV file
file_path = '/Users/sheaandrews/Downloads/adni_betaSet.tsv.gz'
df = pd.read_csv(file_path, delimiter='\t', compression='gzip')
df.set_index('ProbeID', inplace=True)
df.index.name = 'id'


# Read the CSV file into a DataFrame
metadata = pd.read_csv(metadata_path)
metadata.set_index('id', inplace=True)


# Now you can view the DataFrame
print(metadata.head())

class PseudoGeoData:
    def __init__(self, dnam, metadata=None):
        self.dnam = dnam
        self.metadata = metadata

# Since we don't have specific metadata, we'll pass None for now
data = GeoData(df, metadata)

# Try using the modified pseudo_data with the predict method
adni_horvath = gallery.get("Horvathv1").predict(pseudo_data)
adni_hannum = gallery.get("Hannum").predict(pseudo_data)
adni_phenoage = gallery.get("PhenoAge").predict(pseudo_data)

actual_age = metadata['age']
plot_data = pd.DataFrame({
    'Horvath': adni_horvath['Predicted'],
    'Hannum': adni_hannum['Predicted'],
    'PhenoAge': adni_phenoage['Predicted'],
    "Age": actual_age
})
plot_data.index=plot_data['Age']

sn.relplot(data=plot_data, kind="scatter");

adni_horvath = gallery.get("Horvathv1").predict(df)