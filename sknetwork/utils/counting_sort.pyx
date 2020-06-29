# distutils: language = c++
# cython: language_level=3
""" Specific counting sort used in topology.wl_coloring.
Created on June, 2020
@author: Alexis Barreaux <alexis.barreaux@telecom-paris.fr>
"""
import numpy as np
cimport numpy as np

from libcpp.pair cimport pair
from libcpp.vector cimport vector
from libcpp.algorithm cimport sort as csort

cimport cython
cdef bint is_lower(pair[long long, int] p1, pair[long long, int] p2):
    return p1.first < p2.first

@cython.boundscheck(False)
@cython.wraparound(False)
# This function is only used in sknetwork.topology.wl_coloring.pyx.
# For others uses please wrap it and put it in sknetwork.utils.__init__.py
cdef void counting_sort(int length_count, int deg, int [:] count, long long[:] multiset, long long[:] sorted_multiset):
    """Sorts an array by using counting sort, variant of bucket sort.

    Parameters
    ----------
    length_count : int
        The size of count.

    deg: int
        The deg of current node and size of multiset.

    count : np.int32_t[:]
        Buckets to count occurrences.

    multiset : long long[:]
        The array to be sorted.

    sorted_multiset : long long[:]
        The array where multiset will be sorted.
    """

    cdef int total = 0
    cdef int i
    cdef int j

    for i in range(length_count):
        count[i] = 0

    for i in range(deg):
        j =multiset[i]
        count[j] += 1

    for i in range(length_count):
        j = total
        total+= count[i]
        count[i] = j

    for i in range(deg):
        sorted_multiset[count[multiset[i]]] = multiset[i]
        count[multiset[i]] += 1

    for i in range(deg):
        multiset[i] = sorted_multiset[i]

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void counting_sort_all(int[:] indptr, int[:] indices, long long[:,:] multiset, long long[:] labels):
    """Sorts an array by using counting sort, variant of bucket sort.

    Parameters
    ----------
    indptr : int[:]
        Indptr from the csr.sparse adjacency.

    indices: int[:]
        Indices from the csr.sparse adjacency.

    multiset : long long[:,:]
        The multiset where labels will be added and sorted.

    multiset : long long[:]
        The array to be sorted.

    labels : long long[:]
        The current labels of the graph.
    """
    cdef int i
    cdef int deg
    cdef int j
    cdef int j1
    cdef int j2
    cdef int n = indptr.shape[0] -1
    cdef vector[long long] temp
    temp.resize(n)

    for i in range(n):
        j1 = indptr[i]
        j2 = indptr[i + 1]
        deg = j2 - j1
        for j in range(deg):
            j2 = indices[j + j1]
            temp[j] = labels[j2] #label

        csort(temp.begin(), temp.begin() + deg)

        for j in range(deg):
            multiset[i][j]= temp[j]
