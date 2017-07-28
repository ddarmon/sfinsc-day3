# Uncomment v the first time you run, to install igraph:
# install.packages('igraph')

library(igraph)

directed = TRUE

link.type = 'following'
# link.type = 'mentions'
# link.type = 'retweets'

network = read_graph(sprintf("data/twitter_%s.graphml", link.type), format = 'graphml')

# mode = c("collapse", "each", "mutual")

network = as.undirected(network, mode = c("collapse"))

V(network)
E(network)

length(V(network))
length(E(network))

# plot(network)

degree.out = degree(network)

table(degree.out)

Fhat = ecdf(degree.out)

plot(Fhat)
abline(v=50)
plot(table(degree.out))

eigen_centrality.out = eigen_centrality(network)

plot(eigen_centrality.out$vector, type = 'l')

# Note that the eigenvector centrality is *not* 'correct' / 
# will not match Gephi's since igraph does not naturally
# handle the disconnected components.

# Compare to when we consider one of the connected components:

decompose.out = decompose(network) # Determine weakly connected components.

length(decompose.out)

plot(eigen_centrality(decompose.out[[1]])$vector, type = 'l')

# diameter.out = diameter(network)
# show(diameter.out)

embed.out = embed_adjacency_matrix(decompose.out[[1]], no = 2)
plot(embed.out$X)

vs.attributes = get.vertex.attribute(network)

show(vs.attributes$id)

sort(vs.attributes$id)

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

plot(membership.sorted, type = 'l')