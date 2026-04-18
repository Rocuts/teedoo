CREATE TABLE "parties" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"org_id" uuid NOT NULL,
	"tax_id" varchar(32) NOT NULL,
	"tax_id_type" text NOT NULL,
	"name" varchar(255) NOT NULL,
	"address_line1" varchar(255),
	"address_line2" varchar(255),
	"postal_code" varchar(16),
	"city" varchar(128),
	"province" varchar(128),
	"country" varchar(2) DEFAULT 'ES' NOT NULL,
	"email" varchar(255),
	"phone" varchar(32),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "parties_tax_id_type_check" CHECK ("parties"."tax_id_type" IN ('NIF','NIE','CIF','NIF_IVA','PASAPORTE','OTRO')),
	CONSTRAINT "parties_country_format_check" CHECK ("parties"."country" ~ '^[A-Z]{2}$')
);
--> statement-breakpoint
CREATE TABLE "invoices" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"org_id" uuid NOT NULL,
	"series" varchar(32) NOT NULL,
	"number" varchar(64) NOT NULL,
	"issue_date" date NOT NULL,
	"operation_date" date,
	"issuer_id" uuid NOT NULL,
	"recipient_id" uuid NOT NULL,
	"subtotal_cents" integer NOT NULL,
	"irpf_cents" integer DEFAULT 0 NOT NULL,
	"total_cents" integer NOT NULL,
	"currency" varchar(3) DEFAULT 'EUR' NOT NULL,
	"regime" text NOT NULL,
	"operation_type" text NOT NULL,
	"fiscal_region" text NOT NULL,
	"ticketbai_id" varchar(128),
	"ticketbai_hash" varchar(128),
	"verifactu_hash" varchar(128),
	"verifactu_chain_ref" varchar(128),
	"sii_submitted" boolean DEFAULT false NOT NULL,
	"payment_method" varchar(64),
	"payment_iban" varchar(34),
	"payment_due_date" date,
	"notes" text,
	"status" text NOT NULL,
	"rectification" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "invoices_status_check" CHECK ("invoices"."status" IN ('draft','pendingReview','readyToSend','sent','accepted','rejected','cancelled')),
	CONSTRAINT "invoices_regime_check" CHECK ("invoices"."regime" IN ('GENERAL','SIMPLIFICADO','RECARGO_EQUIVALENCIA','REAGP','BIENES_USADOS_REBU','AGENCIAS_VIAJES_REAV','CRITERIO_CAJA_RECC','GRUPO_ENTIDADES_REGE','EXENTO')),
	CONSTRAINT "invoices_operation_type_check" CHECK ("invoices"."operation_type" IN ('F1','F2','F3','F4','F5','R1','R2','R3','R4','R5')),
	CONSTRAINT "invoices_fiscal_region_check" CHECK ("invoices"."fiscal_region" IN ('PENINSULA_BALEARES','CANARIAS','CEUTA','MELILLA','PAIS_VASCO_ARABA','PAIS_VASCO_BIZKAIA','PAIS_VASCO_GIPUZKOA','NAVARRA')),
	CONSTRAINT "invoices_currency_format_check" CHECK ("invoices"."currency" ~ '^[A-Z]{3}$'),
	CONSTRAINT "invoices_totals_sign_check" CHECK ("invoices"."subtotal_cents" IS NOT NULL AND "invoices"."total_cents" IS NOT NULL)
);
--> statement-breakpoint
CREATE TABLE "invoice_lines" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"org_id" uuid NOT NULL,
	"invoice_id" uuid NOT NULL,
	"position" integer NOT NULL,
	"description" text NOT NULL,
	"quantity" varchar(32) NOT NULL,
	"unit_price_cents" integer NOT NULL,
	"discount_percent" varchar(16),
	"vat_rate" text NOT NULL,
	"vat_rate_value" varchar(16) NOT NULL,
	"irpf_rate" varchar(16),
	"exempt_reason" varchar(16),
	"line_total_cents" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "invoice_lines_vat_rate_check" CHECK ("invoice_lines"."vat_rate" IN ('IVA_GENERAL_21','IVA_REDUCIDO_10','IVA_SUPERREDUCIDO_4','IVA_CERO','EXENTO','NO_SUJETO','IGIC_GENERAL_7','IGIC_REDUCIDO_3','IGIC_CERO','IPSI'))
);
--> statement-breakpoint
CREATE TABLE "invoice_vat_breakdowns" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"org_id" uuid NOT NULL,
	"invoice_id" uuid NOT NULL,
	"vat_rate" text NOT NULL,
	"vat_rate_value" varchar(16) NOT NULL,
	"base_cents" integer NOT NULL,
	"vat_cents" integer NOT NULL,
	"recargo_cents" integer DEFAULT 0 NOT NULL,
	CONSTRAINT "invoice_vat_breakdowns_rate_check" CHECK ("invoice_vat_breakdowns"."vat_rate" IN ('IVA_GENERAL_21','IVA_REDUCIDO_10','IVA_SUPERREDUCIDO_4','IVA_CERO','EXENTO','NO_SUJETO','IGIC_GENERAL_7','IGIC_REDUCIDO_3','IGIC_CERO','IPSI'))
);
--> statement-breakpoint
CREATE TABLE "invoice_attachments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"org_id" uuid NOT NULL,
	"invoice_id" uuid NOT NULL,
	"file_name" varchar(255) NOT NULL,
	"mime_type" varchar(128) NOT NULL,
	"size_bytes" integer NOT NULL,
	"url" text NOT NULL,
	"storage_key" text,
	"uploaded_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "invoice_audit" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"org_id" uuid NOT NULL,
	"invoice_id" uuid NOT NULL,
	"at" timestamp with time zone DEFAULT now() NOT NULL,
	"actor_id" varchar(255) NOT NULL,
	"action" varchar(64) NOT NULL,
	"notes" text
);
--> statement-breakpoint
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_issuer_id_parties_id_fk" FOREIGN KEY ("issuer_id") REFERENCES "public"."parties"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoices" ADD CONSTRAINT "invoices_recipient_id_parties_id_fk" FOREIGN KEY ("recipient_id") REFERENCES "public"."parties"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoice_lines" ADD CONSTRAINT "invoice_lines_invoice_id_invoices_id_fk" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoice_vat_breakdowns" ADD CONSTRAINT "invoice_vat_breakdowns_invoice_id_invoices_id_fk" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoice_attachments" ADD CONSTRAINT "invoice_attachments_invoice_id_invoices_id_fk" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoice_audit" ADD CONSTRAINT "invoice_audit_invoice_id_invoices_id_fk" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "parties_org_tax_id_unique" ON "parties" USING btree ("org_id","tax_id");--> statement-breakpoint
CREATE INDEX "parties_org_created_at_idx" ON "parties" USING btree ("org_id","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "invoices_org_series_number_unique" ON "invoices" USING btree ("org_id","series","number");--> statement-breakpoint
CREATE INDEX "invoices_org_created_id_idx" ON "invoices" USING btree ("org_id","created_at","id");--> statement-breakpoint
CREATE INDEX "invoices_org_issue_date_idx" ON "invoices" USING btree ("org_id","issue_date");--> statement-breakpoint
CREATE INDEX "invoices_org_status_idx" ON "invoices" USING btree ("org_id","status");--> statement-breakpoint
CREATE INDEX "invoices_org_issuer_idx" ON "invoices" USING btree ("org_id","issuer_id");--> statement-breakpoint
CREATE INDEX "invoices_org_recipient_idx" ON "invoices" USING btree ("org_id","recipient_id");--> statement-breakpoint
CREATE INDEX "invoice_lines_invoice_idx" ON "invoice_lines" USING btree ("invoice_id","position");--> statement-breakpoint
CREATE INDEX "invoice_lines_org_idx" ON "invoice_lines" USING btree ("org_id");--> statement-breakpoint
CREATE INDEX "invoice_vat_breakdowns_invoice_idx" ON "invoice_vat_breakdowns" USING btree ("invoice_id");--> statement-breakpoint
CREATE INDEX "invoice_vat_breakdowns_org_idx" ON "invoice_vat_breakdowns" USING btree ("org_id");--> statement-breakpoint
CREATE UNIQUE INDEX "invoice_vat_breakdowns_invoice_rate_unique" ON "invoice_vat_breakdowns" USING btree ("invoice_id","vat_rate","vat_rate_value");--> statement-breakpoint
CREATE INDEX "invoice_attachments_invoice_idx" ON "invoice_attachments" USING btree ("invoice_id");--> statement-breakpoint
CREATE INDEX "invoice_attachments_org_idx" ON "invoice_attachments" USING btree ("org_id");--> statement-breakpoint
CREATE INDEX "invoice_audit_invoice_at_idx" ON "invoice_audit" USING btree ("invoice_id","at");--> statement-breakpoint
CREATE INDEX "invoice_audit_org_idx" ON "invoice_audit" USING btree ("org_id");