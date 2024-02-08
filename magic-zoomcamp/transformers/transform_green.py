import pandas as pd

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    print("Rows with zero passengers:", data['passenger_count'].isin([0]).sum())
    data = data[data['passenger_count'] > 0]

    print("Rows with zero trip_distance:", data['trip_distance'].isin([0]).sum())
    data = data[data['trip_distance'] > 0]

    # Convert 'lpep_pickup_datetime' to a date and create 'lpep_pickup_date' column
    data['lpep_pickup_date'] = pd.to_datetime(data['lpep_pickup_datetime']).dt.date

    # Your column renaming code
    data.columns = (data.columns
                .str.replace('(?<=[a-z])(?=[A-Z])', '_', regex=True)
                .str.lower()
             )
             
    print(data["vendor_id"])
    return data

@test
def test_output(output, *args):
    assert output['passenger_count'].isin([0]).sum() == 0, 'There are rides with zero passengers'
    assert output['trip_distance'].isin([0]).sum() == 0, 'There are rides with zero trip distance'
    assert output['vendor_id'].notnull().all(), 'There are null values in the vendor_id column'
