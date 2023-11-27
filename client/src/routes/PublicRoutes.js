import React, { lazy } from 'react';
import { Route, Routes, Navigate } from 'react-router-dom';
import { publicRouteCodes } from '../constants/RouteCodes';
import PublicTemplates from '../templates/PublicTemplates';

const Products = lazy(() => import('../views/public/Products/Products'));
const ProductsForm = lazy(() => import('../views/public/Products/ProductsForm/ProductsForm'));
const ProductsShow = lazy(() => import('../views/public/Products/ProductsShow'));

function PublicRoutes() {
  return (
    <PublicTemplates>
      <Routes>
        <Route
          path={publicRouteCodes.HOME}
          element={<Navigate to={publicRouteCodes.PRODUCTS} replace />}
        />
        <Route path={publicRouteCodes.PRODUCTS} element={<Products />} />
        <Route path={publicRouteCodes.PRODUCTS_CREATE} element={<ProductsForm />} />
        <Route path={publicRouteCodes.PRODUCTS_EDIT} element={<ProductsForm />} />
        <Route path={publicRouteCodes.PRODUCTS_SHOW} element={<ProductsShow />} />
      </Routes>
    </PublicTemplates>
  );
}

export default PublicRoutes;
