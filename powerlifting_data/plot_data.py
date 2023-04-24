from matplotlib import pyplot as plt
import pandas as pd
import os

def save_plot(csv_data, title):
    df = pd.read_csv(csv_data)

    for sex in df['sex'].unique():
        temp_df = df[df['sex'] == sex]

        plt.figure(figsize=(8, 4))
        
        plt.plot(
            temp_df.iloc[:, 0],
            temp_df.iloc[:, -1]
        )

        plt.xticks(rotation=30)
        plt.ylim(temp_df.iloc[:, -1].min() * 0.9, temp_df.iloc[:, -1].max() * 1.1)

        plt.title(f'{title}_{sex}')
        plt.xlabel(temp_df.columns[0])
        plt.ylabel(temp_df.columns[-1])

        plt.savefig(f'plot_graph/{title}_{sex}.png', bbox_inches='tight')

        plt.close()

        print(f'{title}_{sex}.png Saved!')

list_file = os.listdir('query_csv')

print(f'Found {len(list_file)} csv files')

for file in list_file:
    csv_file = 'query_csv/' + file

    save_plot(csv_file, file.replace('.csv', ''))

print('Successfully Saved!')