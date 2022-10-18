select top 1000 * from random.dbo.forage

-- get a picture of the averages where we don't have null values
select Species, AVG(RFQ) as 'Average RFQ', avg(N) as 'Average N', avg(P) as 'Average P', avg(K) as 'Average K'
from random.dbo.forage
where RFQ is not null
group by Species

-- put averages into a temporary table, excluding fescue, in order to get averages for all fescue mixed
drop table if exists #averages
select Species, avg(N) as 'Average N', avg(P) as 'Average P', avg(K) as 'Average K'
into #averages
from random.dbo.forage
where Species like 'Fescue%' and Species <> 'Fescue'
group by Species

-- get our averages for fescue mixed
select avg([Average N]), avg([Average P]), avg([Average K])
from #averages

select top 1000 * from random.dbo.forage

-- do the same process using temp tables for counts
drop table if exists #countswithoutfescuemixed
select Species, month, count(1) as 'Sample Count'
into #countswithoutfescuemixed
from random.dbo.forage
where Species not like 'Fescue%' or Species = 'Fescue'
group by Species, month

select * from #countswithoutfescuemixed

------ next steps: combine fescue and other duplicate species for counts
drop table if exists #fescuemixedcounts
select Species, month, count(1) as 'Sample Count'
into #fescuemixedcounts
from random.dbo.forage
where Species like 'Fescue%' and species <> 'Fescue'
group by Species, month

select Species, month, sum([Sample Count]) over (partition by [month]) as 'Sample Count'
from #fescuemixedcounts
group by Species, month, [Sample Count]