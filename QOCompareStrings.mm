//  QOLocalizableStrings
//
//  QOCompareStrings.mm
//
//  Created by Sergey Krotkih on 27.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//
// http://ru.wikibooks.org/wiki/%D0%A0%D0%B0%D1%81%D1%81%D1%82%D0%BE%D1%8F%D0%BD%D0%B8%D0%B5_%D0%9B%D0%B5%D0%B2%D0%B5%D0%BD%D1%88%D1%82%D0%B5%D0%B9%D0%BD%D0%B0

#include <vector>
#include <algorithm>
#include <string>
#import "QOCompareStrings.h"

template <typename T>
typename T::size_type levenshtein_distance(const T & src, const T & dst)
{
    const typename T::size_type m = src.size();
    const typename T::size_type n = dst.size();
    if (m == 0) 
    {
        return n;
    }
    if (n == 0) 
    {
        return m;
    }
    
    std::vector< std::vector<typename T::size_type> > matrix(m + 1);
    
    for (typename T::size_type i = 0; i <= m; ++i) 
    {
        matrix[i].resize(n + 1);
        matrix[i][0] = i;
    }
    for (typename T::size_type i = 0; i <= n; ++i) 
    {
        matrix[0][i] = i;
    }
    
    typename T::size_type above_cell, left_cell, diagonal_cell, cost;
    
    for (typename T::size_type i = 1; i <= m; ++i) 
    {
        for(typename T::size_type j = 1; j <= n; ++j) 
        {
            cost = src[i - 1] == dst[j - 1] ? 0 : 1;
            above_cell = matrix[i - 1][j];
            left_cell = matrix[i][j - 1];
            diagonal_cell = matrix[i - 1][j - 1];
            matrix[i][j] = std::min(std::min(above_cell + 1, left_cell + 1), diagonal_cell + cost);
        }
    }
    
    return matrix[m][n];
}

@implementation QOCompareStrings

+ (int) distanceSimilarStrings: (NSString*) str1 secondStr: (NSString*) str2
{
    std::string str1_ = std::string([str1 UTF8String]);
    std::string str2_ = std::string([str2 UTF8String]);
    std::string::size_type distance = levenshtein_distance(str1_, str2_); 
    return distance;
}

@end
