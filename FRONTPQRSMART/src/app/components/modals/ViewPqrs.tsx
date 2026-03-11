"use client";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";

type Pqrs = {
  mediumAnswer: string;
  description: string;
  date: Date;
  answer?: string;
  category: {
    idCategory: number;
    nameCategory: string;
  };
  requestState: {
    idRequestState: number;
    nameRequestState: string;
  };
  dependence: {
    idDependence: number;
    nameDependence: string;
  };
  requestType: {
    idRequestType: number;
    nameRequestType: string;
  };
};
export default function ViewPqrs({
  onClose,
  pqrs,
}: {
  onClose: () => void;
  pqrs?: Pqrs;
}) {
  const { t } = useTranslation("common");
  const [formData, setFormData] = useState<Pqrs>({
    mediumAnswer: "",
    description: "",
    date: new Date(),
    answer: undefined,
    requestType: { idRequestType: 0, nameRequestType: "" },
    dependence: { idDependence: 0, nameDependence: "" },
    requestState: { idRequestState: 0, nameRequestState: "" },
    category: { idCategory: 0, nameCategory: "" },
  });

  useEffect(() => {
    if (pqrs) setFormData(pqrs);
  }, [pqrs]);

  const handleChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement
    >,
  ) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };
  const getAnswerValue = () => {
    switch (formData.requestState.nameRequestState) {
      case "Finalizado":
        return formData.answer || "";

      case "Pendiente":
        return "Pending answer";

      default:
        return "The PQRS has been closed";
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
      {/* Contenedor del modal */}
      <div className="bg-white rounded-2xl shadow-xl w-96 p-6 relative animate-fade-in">
        {/* Botón para cerrar */}
        <button
          onClick={onClose}
          className="absolute top-3 right-3 text-gray-400 hover:text-gray-600 text-lg"
        >
          ✕
        </button>

        {/* Contenido del modal */}
        <h2 className="text-xl font-semibold text-gray-800 mb-4">
          {t("user.pqrs.pqrs_modal.title")}
        </h2>

        <form className="space-y-4">
          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.type_label")}
            </label>
            <input
              type="text"
              name="requestType"
              value={formData.requestType.nameRequestType}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.dependencia_label")}
            </label>
            <input
              type="text"
              name="dependencia"
              value={formData.dependence.nameDependence}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.category_label")}
            </label>
            <input
              type="text"
              name="category"
              value={formData.category.nameCategory}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.medium_answer_label")}
            </label>
            <input
              type="text"
              name="mediumAnswer"
              value={formData.mediumAnswer}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.description_label")}
            </label>
            <textarea
              name="description"
              value={formData.description}
              rows={4}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.answer_label")}
            </label>
            <input
              type="text"
              name="answer"
              value={getAnswerValue()}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>

          <div>
            <label className="block text-sm text-gray-600 mb-1">
              {t("user.pqrs.pqrs_modal.status_label")}
            </label>
            <input
              type="text"
              name="status"
              value={formData.requestState.nameRequestState}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              disabled
            />
          </div>
        </form>
      </div>
    </div>
  );
}
