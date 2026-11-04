"""firstname column name fixed

Revision ID: 80a22ad8fe19
Revises: 84f6e29455b1
Create Date: 2026-10-23 18:07:33.569035

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '80a22ad8fe19'
down_revision: Union[str, Sequence[str], None] = '84f6e29455b1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
