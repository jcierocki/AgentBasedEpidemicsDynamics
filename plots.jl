#### preparing plots

using DataFrames, CSV
using Plots; pyplot()

## data preparation

wig_csv_path = "https://stooq.pl/q/d/l/?s=wig&d1=20200101&d2=20200430&i=d"
sp500_csv_path = "https://stooq.pl/q/d/l/?s=^spx&d1=20200101&d2=20200501&i=d"

# download(wig_csv_path, "data/wig.csv")
# download(sp500_csv_path, "data/sp500.csv")

df_wig = CSV.read("data/wig.csv")[:, [:Data, :Zamkniecie, :Wolumen]]
df_sp500 = CSV.read("data/sp500.csv")[:, [:Data, :Zamkniecie, :Wolumen]]

rename!(df_wig, [:Zamkniecie => :wig, :Wolumen => :volume_wig])
rename!(df_sp500, [:Zamkniecie => :sp500, :Wolumen => :volume_sp500])

df_all = join(df_wig, df_sp500, on = :Data, kind = :inner)
rename!(df_all, :Data => :date)

plt = plot()
plot!(plt, df_all.date, df_all.sp500, label = "sp500")
plot!(twinx(), df_all.date, df_all.wig, c = :red, label = "wig", legend = :bottomright)

savefig("data/wig_sp500.png")
