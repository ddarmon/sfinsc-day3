# Uncomment v the first time you run, to install igraph:
# install.packages('igraph')

library(igraph)

directed = FALSE

link.types = c('following', 'mentions', 'retweets')
# link.types = c('mentions', 'retweets')

membership.by.type = list()

for (link.type in link.types){
  network = read_graph(sprintf("data/twitter_%s.graphml", link.type), format = 'graphml')
  
  # mode = c("collapse", "each", "mutual")
  
  network = as.undirected(network, mode = c("collapse"))
  
  # The community detection algorithms in igraph are:
  # 
  # cluster_edge_betweenness, cluster_fast_greedy, cluster_label_prop, cluster_leading_eigen, cluster_louvain, cluster_optimal, cluster_spinglass, cluster_walktrap
  
  comms.fg = cluster_fast_greedy(network)
  
  comm.labels.fg = communities(comms.fg)
  
  length(comm.labels.fg)
  
  comm.sizes = sapply(comm.labels.fg, length)
  
  table(comm.sizes)
  plot(table(comm.sizes))
  
  plot(membership(comms.fg), type = 'l')
  
  membership.by.nodes = membership(comms.fg)
  
  inds.lex = order(vs.attributes$id)
  membership.sorted = membership.by.nodes[inds.lex]
  
  membership.by.type[[link.type]] = membership.sorted
  
  plot(membership.sorted, type = 'l')
}

vi.mat = matrix(NA, ncol = length(link.types), nrow = length(link.types))

for (i in 1:(length(link.types)-1)){
	for (j in (i + 1):length(link.types)){
		# method = c("vi", "nmi", "split.join", "rand", "adjusted.rand")
		vi = compare(membership.by.type[[link.types[i]]], membership.by.type[[link.types[j]]], method = 'vi')
		vi.mat[i, j] = vi/(2*log2(length(V(network))))
	}
}

# Can perform permutation test to determine how likely the observed vi would be
# assuming *no* association between the communities of the two networks.
# One of those permutations would be:

# vi = compare(membership.by.type$mentions, sample(membership.by.type$retweets), method = 'vi')
# vi/(2*log2(length(V(network))))