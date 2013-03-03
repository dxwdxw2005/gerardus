// Copyright (c) 1997  ETH Zurich (Switzerland).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
// You can redistribute it and/or modify it under the terms of the GNU
// General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Licensees holding a valid commercial license may use this file in
// accordance with the commercial license agreement provided with the software.
//
// This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
// WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// $URL: svn+ssh://scm.gforge.inria.fr/svn/cgal/branches/releases/CGAL-4.0-branch/Polyhedron_IO/include/CGAL/IO/Polyhedron_VRML_2_ostream.h $
// $Id: Polyhedron_VRML_2_ostream.h 67117 2012-01-13 18:14:48Z lrineau $
// 
//
// Author(s)     : Lutz Kettner  <kettner@mpi-sb.mpg.de>

#ifndef CGAL_IO_POLYHEDRON_VRML_2_OSTREAM_H
#define CGAL_IO_POLYHEDRON_VRML_2_OSTREAM_H 1

#include <CGAL/basic.h>
#include <CGAL/IO/VRML_2_ostream.h>
#include <CGAL/IO/File_writer_VRML_2.h>
#include <CGAL/IO/generic_print_polyhedron.h>
#include <CGAL/Polyhedron_3.h>
#include <iostream>

namespace CGAL {

template < class Traits,
           class Items,
#ifndef CGAL_CFG_NO_TMPL_IN_TMPL_PARAM
           template < class T, class I, class A>
#endif
           class HDS, class Alloc>
VRML_2_ostream&
operator<<( VRML_2_ostream& out,
            const Polyhedron_3<Traits,Items,HDS,Alloc>& P) {
    File_writer_VRML_2  writer;
    generic_print_polyhedron( out.os(), P, writer);
    return out;
}

} //namespace CGAL
#endif // CGAL_IO_POLYHEDRON_VRML_2_OSTREAM_H //
// EOF //