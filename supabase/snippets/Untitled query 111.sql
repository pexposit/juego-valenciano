SELECT jsonb_pretty(jsonb_build_object(
    'tables', (
        SELECT jsonb_agg(
            jsonb_build_object(
                'table', t.table_name,
                'columns', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'name', c.column_name,
                            'type', c.udt_name,
                            'nullable', c.is_nullable = 'YES',
                            'default', c.column_default
                        ) ORDER BY c.ordinal_position
                    )
                    FROM information_schema.columns c
                    WHERE c.table_name = t.table_name AND c.table_schema = 'public'
                ),
                'foreign_keys', (
                    SELECT COALESCE(jsonb_agg(
                        jsonb_build_object(
                            'column', kcu.column_name,
                            'references_table', ccu.table_name,
                            'references_column', ccu.column_name
                        )
                    ), '[]'::jsonb)
                    FROM information_schema.table_constraints tc
                    JOIN information_schema.key_column_usage kcu
                        ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
                    JOIN information_schema.constraint_column_usage ccu
                        ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
                    WHERE tc.table_name = t.table_name 
                      AND tc.constraint_type = 'FOREIGN KEY'
                      AND tc.table_schema = 'public'
                )
            )
        )
        FROM information_schema.tables t
        WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE'
    )
));