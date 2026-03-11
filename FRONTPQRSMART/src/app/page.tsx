"use client";

import { useEffect } from "react";
import Banner from "./components/home/banner";
import Footer from "./components/home/footer";
import Header from "./components/home/header";
import Steps from "./components/home/steps";
import Intro from "./components/home/intro";

function page() {
  useEffect(() => {
    document.title = "home - PQRSmart";
  }, []);

  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      <Header />
      <Banner />
      <Intro />
      <Steps />
      <Footer />
    </div>
  );
}

export default page;
